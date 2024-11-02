# -----------------------------------------------------------------------------
# Outputs for Phantom Server Instance in GCP
# These outputs provide useful information about the Phantom server instance,
# such as its name, IP addresses (internal and external), and self-link.
# -----------------------------------------------------------------------------

# Output: Name of the Phantom server instance
output "phantom_server_name" {
  description = "The name of the Phantom server instance"
  value       = google_compute_instance.phantom_server[*].name
}

# Output: Internal IP of the Phantom server instance
output "phantom_server_internal_ip" {
  description = "The internal IP address of the Phantom server instance"
  value       = google_compute_instance.phantom_server[*].network_interface[0].network_ip
}

# Output: External IP of the Phantom server instance (if assigned)
output "phantom_server_external_ip" {
  description = "The external IP address of the Phantom server instance, if assigned"
  value       = google_compute_instance.phantom_server[*].network_interface[0].access_config[0].nat_ip
}

# Output: Self-link of the Phantom server instance for direct reference in GCP
output "phantom_server_self_link" {
  description = "The self-link of the Phantom server instance"
  value       = google_compute_instance.phantom_server[*].self_link
}
