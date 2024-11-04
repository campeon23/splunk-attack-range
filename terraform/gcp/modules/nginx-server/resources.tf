# -----------------------------------------------------------------------------
# NGINX Server Instance Configuration for GCP
# This configuration sets up an NGINX server instance in Google Cloud Platform
# with custom machine specifications, disk settings, and network configurations.
# -----------------------------------------------------------------------------

# Google Compute Instance for NGINX Server
resource "google_compute_instance" "nginx_server" {
  count        = var.nginx_server.nginx_server == 1 ? 1 : 0
  name         = "ar-nginx-${var.general.key_name}-${var.general.attack_range_name}"
  machine_type = var.nginx_server.machine_type  # Specifies instance type, e.g., "e2-small"
  zone         = var.gcp.zone                   # Define the desired GCP zone

  # Boot Disk Configuration
  # Configures the boot disk with specified image, size, and type
  boot_disk {
    initialize_params {
      image = var.nginx_server.image  # GCP image ID, e.g., "ubuntu-2004-focal-v20210817"
      size  = var.nginx_server.disk_size  # Disk size in GB
      type  = var.nginx_server.disk_type  # Disk type, e.g., "pd-balanced"
    }
    auto_delete = true
  }

  # Network Interface Configuration
  # Assigns network settings, including an optional static internal IP and external IP assignment
  network_interface {
    network    = var.vpc_network
    subnetwork = var.subnetwork
    network_ip = var.nginx_server.network_ip  # Static internal IP, if specified
    access_config {                           # Enables external IP assignment
      nat_ip = length(google_compute_address.nginx_server_ip) > count.index ? google_compute_address.nginx_server_ip[count.index].address : null
    }
  }

  # Assign the NGINX Service Account to this instance
    service_account {
        email  = var.nginx_sa_email
        scopes = ["https://www.googleapis.com/auth/cloud-platform"]
    }

  # Metadata for SSH and Custom Commands
  # Adds SSH key metadata for instance access
  metadata = {
    ssh-keys = "ubuntu:${file(var.gcp.public_key_path)}"
  }

  # Instance Tags and Labels
  # Tags and labels to help categorize and identify the instance in GCP
  tags = ["gcp-infrastructure", "nginx-server", "attack-range"]
  labels = {
    name = "ar-nginx-${var.general.key_name}-${var.general.attack_range_name}"
  }

  # Remote Provisioner: Initial Remote Connection Check
  # Executes a command to confirm instance boot using SSH
  provisioner "remote-exec" {
    inline = ["echo booted"]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = self.network_interface[0].access_config[0].nat_ip
      private_key = file(var.gcp.private_key_path)
    }
  }

  # Local Provisioner: Generate Ansible Variables for NGINX Server Configuration
  # Creates a JSON file containing variables to be used in the Ansible playbook
  provisioner "local-exec" {
    working_dir = "../ansible"
    command = <<-EOT
      cat <<EOF > vars/nginx_vars.json
      {
        "ansible_python_interpreter": "/usr/bin/python3",
        "general": ${jsonencode(var.general)},
        "splunk_server": ${jsonencode(var.splunk_server)},
        "nginx_server": ${jsonencode(var.nginx_server)}
      }
      EOF
    EOT
  }

  # Local Provisioner: Execute Ansible Playbook for NGINX Server Setup
  # Runs the Ansible playbook to configure the NGINX server with the generated variables
  provisioner "local-exec" {
    working_dir = "../ansible"
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ubuntu --private-key '${var.gcp.private_key_path}' -i '${self.network_interface[0].access_config[0].nat_ip},' nginx_server.yml -e @vars/nginx_vars.json"
  }
}

# Static External IP Allocation for NGINX Server Instance
# Provisions a static IP for the NGINX server if elastic IPs are enabled
resource "google_compute_address" "nginx_server_ip" {
  count  = (var.nginx_server.nginx_server == 1 && var.gcp.use_elastic_ips == "1") ? 1 : 0
  name   = "nginx-server-ip-${count.index}"
  region = var.gcp.region
}
