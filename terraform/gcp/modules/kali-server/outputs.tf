# -----------------------------------------------------------------------------
# Output Variables for Kali Linux Instance
# These output variables provide essential information about the Kali server instance,
# including its name, public IP (if assigned), and internal IP.
# -----------------------------------------------------------------------------

# Output the instance name of the Kali server for easy reference
output "kali_server_instance_name" {
  value       = google_compute_instance.kali_machine[0].name
  description = "Name of the Kali server instance for identification in GCP"
}

# Output the public IP address of the Kali server instance
# This IP is accessible if an external IP is assigned to the instance
output "kali_server_public_ip" {
  value       = google_compute_instance.kali_machine[0].network_interface[0].access_config[0].nat_ip
  description = "Public IP address of the Kali server instance, used for external access"
}

# Output the internal IP address of the Kali server instance
# This IP is used for internal communication within the VPC
output "kali_server_internal_ip" {
  value       = google_compute_instance.kali_machine[0].network_interface[0].network_ip
  description = "Internal IP address of the Kali server instance, used for VPC-internal access"
}
