# -----------------------------------------------------------------------------
# Snort Sensor and Packet Mirroring Configuration in GCP
# This configuration deploys a Snort IDS sensor on a Google Compute instance,
# sets up packet mirroring to monitor traffic, and includes associated resources
# for load balancing, health checks, and network interface configuration.
# -----------------------------------------------------------------------------

# Snort Sensor Instance Configuration
resource "google_compute_instance" "snort_sensor" {
  count        = var.snort_server.snort_server == 1 ? 1 : 0
  name         = "ar-snort-${var.general.key_name}-${var.general.attack_range_name}"
  machine_type = var.snort_server.machine_type            # Equivalent to AWS "m5.2xlarge" for performance needs
  zone         = var.gcp.zone

  # Boot disk configuration for the Snort instance
  boot_disk {
    initialize_params {
      image = var.snort_server.image      # Specify appropriate Snort-compatible OS image (e.g., "ubuntu-2204-lts")
      size  = var.snort_server.disk_size  # Disk size in GB
      type  = var.snort_server.disk_type  # Disk type, e.g., "pd-ssd"
    }
    auto_delete = true
  }

  # Network configuration for internal/external IP assignment
  network_interface {
    network    = var.vpc_network
    subnetwork = var.subnetwork
    network_ip = var.snort_server.network_ip  # Optionally assign a static internal IP

    access_config {
      # Assign a public IP if required; otherwise, set to null
      nat_ip = length(google_compute_address.snort_ip) > count.index ? google_compute_address.snort_ip[count.index].address : null
    }
  }

  # Assign the Snort Service Account to this instance
  service_account {
    email  = var.snort_sa_email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  # SSH key metadata for user access
  metadata = {
    ssh-keys = "ubuntu:${file(var.gcp.public_key_path)}"
  }

  # Tags for firewall and organizational grouping
  tags = ["gcp-infrastructure", "snort-server", "attack-range"]

  # Instance labeling for identification in GCP
  labels = {
    name = "ar-snort-${var.general.key_name}-${var.general.attack_range_name}"
  }

  # Remote execution provisioner for instance readiness check
  provisioner "remote-exec" {
    inline = ["echo booted"]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = self.network_interface[0].access_config[0].nat_ip
      private_key = file(var.gcp.private_key_path)
    }
  }

  # Local provisioner for Ansible playbook setup
  provisioner "local-exec" {
    working_dir = "../ansible"
    command = <<-EOT
      cat <<EOF > vars/snort_vars.json
      {
        "ansible_python_interpreter": "/usr/bin/python3",
        "general": ${jsonencode(var.general)},
        "splunk_server": ${jsonencode(var.splunk_server)},
        "snort_server": ${jsonencode(var.snort_server)}
      }
      EOF
    EOT
  }

  # Running the Ansible playbook for Snort configuration
  provisioner "local-exec" {
    working_dir = "../ansible"
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ubuntu --private-key '${var.gcp.private_key_path}' -i '${self.network_interface[0].access_config[0].nat_ip},' snort_server.yml -e @vars/snort_vars.json"
  }
}

# Packet Mirroring Configuration for Snort IDS
resource "google_compute_packet_mirroring" "snort_packet_mirroring" {
  count = var.snort_server.snort_server == 1 ? 1 : 0
  name  = "snort-packet-mirroring-${var.general.key_name}-${var.general.attack_range_name}"
  region = var.gcp.region

  # Mirroring packets from the network associated with the Snort sensor
  network {
    url = var.vpc_network
  }

  # Mirror resources targeting the Snort instance
  mirrored_resources {
    instances {
      url = google_compute_instance.snort_sensor[0].self_link
    }
  }

  # Filtering criteria: mirror both ingress and egress traffic for all IP ranges
  filter {
    direction = "BOTH"
    cidr_ranges = ["0.0.0.0/0"]
  }

  # Configure the internal load balancer to collect mirrored packets
  collector_ilb {
    url = google_compute_forwarding_rule.snort_forwarding_rule.self_link
  }
}

# Internal Forwarding Rule for Packet Collection by Snort
resource "google_compute_forwarding_rule" "snort_forwarding_rule" {
  name                   = "snort-mirror-forwarding-rule"
  region                 = var.gcp.region
  load_balancing_scheme  = "INTERNAL"
  backend_service        = google_compute_region_backend_service.snort_backend_service.self_link
  all_ports              = true
  ip_protocol            = "TCP"
  network                = var.vpc_network
  subnetwork             = var.subnetwork
  is_mirroring_collector = true
}

# Backend Service for Load Balancing Snort Traffic
resource "google_compute_region_backend_service" "snort_backend_service" {
  name           = "snort-backend-service"
  region         = var.gcp.region
  protocol       = "TCP"
  health_checks  = [google_compute_health_check.snort_health_check.id]

  backend {
    group          = google_compute_instance_group.snort_group.self_link
    balancing_mode = "CONNECTION"
  }
}

# Instance Group for Snort Server Load Balancing
resource "google_compute_instance_group" "snort_group" {
  name       = "snort-instance-group"
  zone       = var.gcp.zone
  instances  = [for instance in google_compute_instance.snort_sensor : instance.self_link]
  network    = var.vpc_network
}

# Static External IP for Snort Server (optional)
resource "google_compute_address" "snort_ip" {
  count  = (var.snort_server.snort_server == 1 && var.gcp.use_elastic_ips == "1") ? 1 : 0
  name   = "snort-ip-${count.index}"
  region = var.gcp.region
}

# Health Check for Snort Backend Service
resource "google_compute_health_check" "snort_health_check" {
  name               = "snort-health-check"
  check_interval_sec = 10
  timeout_sec        = 5

  tcp_health_check {
    port = 80  # Adjust to an appropriate port for health checking
  }
}
