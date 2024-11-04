# -----------------------------------------------------------------------------
# Output Variables for Kali Linux Instance
# These output variables provide essential information about the Kali Server Instance,
# including its name, public IP (if assigned), and internal IP.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# These outputs can be used for verification or additional configuration steps.
# -----------------------------------------------------------------------------

# Output the name of the Kali Linux Service Account
# This service account is likely used for managing the Kali Server Instance
output "kali_sa_email" {
  description = "The email address of the Kali Linux Service Account"
  value       = var.kali_sa_email 
}

# Output the roles assigned to the Kali Linux Service Account
# These roles define the permissions and access levels for the Kali server
output "kali_sa_roles" {
  description = "Roles assigned to the Kali Linux Service Account"
  value       = var.kali_sa_roles
}

# Output the instance name of the Kali server for easy reference
output "kali_server_instance_name" {
  description = "Name of the Kali Server Instance for identification in GCP"
  value       = google_compute_instance.kali_machine[0].name
}

# Output the public IP address of the Kali Server Instance
# This IP is accessible if an external IP is assigned to the instance
output "kali_server_public_ip" {
  description = "Public IP address of the Kali Server Instance, used for external access"
  value       = google_compute_instance.kali_machine[0].network_interface[0].access_config[0].nat_ip
}

# Output the internal IP address of the Kali Server Instance
# This IP is used for internal communication within the VPC
output "kali_server_internal_ip" {
  description = "Internal IP address of the Kali Server Instance, used for VPC-internal access"
  value       = google_compute_instance.kali_machine[0].network_interface[0].network_ip
}