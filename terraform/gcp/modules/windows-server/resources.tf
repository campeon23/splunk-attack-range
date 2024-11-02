# -----------------------------------------------------------------------------
# Windows Server Instance Configuration
# -----------------------------------------------------------------------------
# This resource block configures a Windows Server instance in Google Cloud Platform.
# The instance includes disk, network, metadata settings, and remote provisioning
# to set up essential configurations for attack-range simulations.
# -----------------------------------------------------------------------------

resource "google_compute_instance" "windows_server" {
  count        = length(var.windows_servers)
  name         = "ar-win-${var.general.key_name}-${var.general.attack_range_name}-${count.index}"
  machine_type = (var.zeek_server.zeek_server == 1 || var.snort_server.snort_server == 1) ? var.snort_server.machine_type : var.zeek_server.machine_type
  zone         = var.gcp.zone

  # Boot Disk Configuration
  boot_disk {
    initialize_params {
      image = var.windows_servers[count.index].image      # Windows Server image ID
      size  = var.windows_servers[count.index].disk_size  # Disk size in GB
      type  = var.windows_servers[count.index].disk_type  # Disk type, e.g., "pd-ssd"
    }
    auto_delete = true
  }

  # Network Interface Configuration
  network_interface {
    network    = var.vpc_network
    subnetwork = var.subnetwork
    network_ip = "10.0.2.${14 + count.index}"  # Assigns static internal IP
    access_config {                            # Assigns an external NAT IP if available
      nat_ip = length(google_compute_address.windows_ip) > count.index ? google_compute_address.windows_ip[count.index].address : null
    }
  }

  # Metadata for Windows Startup Script
  # This script configures WinRM, firewall rules, and enables the Administrator account.
  metadata = {
    windows-startup-script-ps1 = <<-EOF
        $admin = [adsi]("WinNT://./Administrator, user")
        $admin.PSBase.Invoke("SetPassword", "${var.general.attack_range_password}")
        if ($?) {
            Add-Content -Path C:\startup_log.txt -Value "Password set successfully for Administrator."
        } else {
            Add-Content -Path C:\startup_log.txt -Value "Failed to set password for Administrator."
        }
        net user Administrator /active:yes
        if ($admin.AccountDisabled -eq $false) {
            Add-Content -Path C:\startup_log.txt -Value "Administrator account enabled."
        } else {
            Add-Content -Path C:\startup_log.txt -Value "Administrator account NOT enabled."
        }
        winrm quickconfig -q
        winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="1024"}'
        winrm set winrm/config '@{MaxTimeoutms="1800000"}'
        winrm set winrm/config/service '@{MaxMemoryPerShellMB="512"}'
        winrm set winrm/config/service '@{AllowUnencrypted="true"}'
        Set-Item -Path WSMan:\localhost\Service\AllowUnencrypted -Value true
        winrm set winrm/config/service/auth '@{Basic="true"}'
        $PublicIP = Invoke-RestMethod -Uri "http://ifconfig.me/ip"
        $Cert = New-SelfSignedCertificate -DnsName $PublicIP -CertStoreLocation "Cert:\LocalMachine\My"
        $Thumbprint = $Cert.Thumbprint
        try {
            # Create HTTP listener on port 5985
            winrm create winrm/config/Listener?Address=*+Transport=HTTP+Port=5985
        } catch {
            Write-Host "HTTP listener on port 5985 already exists."
        }

        try {
            # Create HTTPS listener on port 5986
            winrm create winrm/config/Listener?Address=*+Transport=HTTPS @{Hostname="$PublicIP"; CertificateThumbprint="$Thumbprint"}
        } catch {
            Write-Host "HTTPS listener on port 5986 already exists."
        }
        netsh advfirewall firewall add rule name="WinRM HTTP" protocol=TCP dir=in localport=5985 action=allow
        netsh advfirewall firewall add rule name="WinRM HTTPS" protocol=TCP dir=in localport=5986 action=allow
        net stop winrm
        sc.exe config winrm start=auto
        net start winrm
        Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 0
        Enable-PSRemoting -SkipNetworkProfileCheck -Force
        $drive_letter = "C"
        $size = (Get-PartitionSupportedSize -DriveLetter $drive_letter)
        Resize-Partition -DriveLetter $drive_letter -Size $size.SizeMax
        winrm enumerate winrm/config/Listener
    EOF
  }

  # Tags and Labels for Instance Identification
  tags = ["gcp-infrastructure", "windows-server", "attack-range"]
  labels = {
    name = "ar-win-${var.general.key_name}-${var.general.attack_range_name}-${count.index}"
  }

  # Provisioners for Initial Setup
  # Remote Exec - Verifies instance setup over WinRM
  provisioner "remote-exec" {
    inline = ["echo booted"]
    connection {
      type     = "winrm"
      user     = "Administrator"
      password = var.general.attack_range_password
      host     = self.network_interface[0].access_config[0].nat_ip
      port     = 5985
      insecure = true
      https    = false
      timeout  = "20m"
    }
  }

  # Local Exec - Generates Ansible variables and runs playbook
  provisioner "local-exec" {
    working_dir = "../ansible"
    command = <<-EOT
      cat <<EOF > vars/windows_vars_${count.index}.json
      {
        "ansible_user": "Administrator",
        "ansible_password": "${var.general.attack_range_password}",
        "attack_range_password": "${var.general.attack_range_password}",
        "general": ${jsonencode(var.general)},
        "splunk_server": ${jsonencode(var.splunk_server)},
        "simulation": ${jsonencode(var.simulation)},
        "windows_servers": ${jsonencode(var.windows_servers[count.index])}
      }
      EOF
    EOT
  }

  provisioner "local-exec" {
    working_dir = "../ansible"
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i '${self.network_interface[0].access_config[0].nat_ip},' windows.yml -e @vars/windows_vars_${count.index}.json -vvv"
  }
}

# -----------------------------------------------------------------------------
# Static IP Configuration for Windows Server
# -----------------------------------------------------------------------------
# Allocates a static external IP for each Windows instance if elastic IPs are enabled.
# -----------------------------------------------------------------------------
resource "google_compute_address" "windows_ip" {
  count  = (var.gcp.use_elastic_ips == "1") ? length(var.windows_servers) : 0
  name   = "windows-ip-${count.index}"
  region = var.gcp.region
}