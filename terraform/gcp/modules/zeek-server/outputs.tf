# -----------------------------------------------------------------------------
# Outputs for Zeek Server Configuration
# -----------------------------------------------------------------------------
# This section defines output values for the Zeek server and its associated
# packet mirroring configuration in Google Cloud Platform (GCP). Outputs include
# instance details, network configuration, and mirroring collector information.
# These outputs allow easy access to the server's details and status from the
# Terraform console and other automated processes.
# -----------------------------------------------------------------------------

# Output: Zeek Server Instance Name
output "zeek_server_name" {
  description = "The name of the Zeek server instance"
  value       = google_compute_instance.zeek_sensor[*].name
}

# Output: Zeek Server Internal IP
output "zeek_server_internal_ip" {
  description = "The internal IP address of the Zeek server instance"
  value       = google_compute_instance.zeek_sensor[*].network_interface[0].network_ip
}

# Output: Zeek Server External IP
output "zeek_server_external_ip" {
  description = "The external IP address of the Zeek server instance, if assigned"
  value       = google_compute_instance.zeek_sensor[*].network_interface[0].access_config[0].nat_ip
}

# Output: Zeek Server Self-Link
output "zeek_server_self_link" {
  description = "The self-link of the Zeek server instance"
  value       = google_compute_instance.zeek_sensor[*].self_link
}

# Output: Zeek Packet Mirroring Status
output "zeek_packet_mirroring_status" {
  description = "The status of the Packet Mirroring for the Zeek server"
  value       = google_compute_packet_mirroring.zeek_packet_mirroring[*].name
}

# Output: Zeek Packet Mirroring Collector Self-Link
output "zeek_packet_mirroring_collector" {
  description = "The self-link of the internal load balancer acting as the packet mirroring collector for the Zeek server"
  value       = google_compute_forwarding_rule.zeek_forwarding_rule.self_link
}
