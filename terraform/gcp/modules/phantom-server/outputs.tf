# -----------------------------------------------------------------------------
# Outputs for Phantom Server Instance in GCP
# These outputs provide useful information about the Phantom Server Instance,
# such as its name, IP addresses (internal and external), and self-link.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# These outputs can be used for verification or additional configuration steps.
# -----------------------------------------------------------------------------

# Output: Phantom Service Account Email
# Provides the email address of the Phantom Service Account, if created
output "phantom_sa_email" {
  description = "The email address of the Phantom Service Account"
  value       = var.phantom_sa_email
}

# Output: phantom Server Roles
# Lists the roles assigned to the Phantom Service Account, if created
output "phantom_sa_roles" {
  description = "Roles assigned to the Phantom Service Account"
  value       = var.phantom_sa_roles
}

# Output: Name of the Phantom Server Instance
output "phantom_server_name" {
  description = "The name of the Phantom Server Instance"
  value       = google_compute_instance.phantom_server[*].name
}

# Output: Internal IP of the Phantom Server Instance
output "phantom_server_internal_ip" {
  description = "The internal IP address of the Phantom Server Instance"
  value       = google_compute_instance.phantom_server[*].network_interface[0].network_ip
}

# Output: External IP of the Phantom Server Instance (if assigned)
output "phantom_server_external_ip" {
  description = "The external IP address of the Phantom Server Instance, if assigned"
  value       = google_compute_instance.phantom_server[*].network_interface[0].access_config[0].nat_ip
}

# Output: Self-link of the Phantom Server Instance for direct reference in GCP
output "phantom_server_self_link" {
  description = "The self-link of the Phantom Server Instance"
  value       = google_compute_instance.phantom_server[*].self_link
}
