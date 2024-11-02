# -----------------------------------------------------------------------------
# Output Variables for Linux Server Instances
# These outputs provide essential details about the Linux server instances,
# including instance names, IP addresses, instance self-links, and unique IDs.
# -----------------------------------------------------------------------------

# Output: Names of Linux Server Instances
# Returns the names of all deployed Linux server instances
output "linux_server_names" {
  description = "The names of the Linux server instances"
  value       = [for instance in google_compute_instance.linux_server : instance.name]
}

# Output: Internal IP Addresses of Linux Server Instances
# Lists the internal IP addresses assigned to each Linux server instance within the VPC
output "linux_server_internal_ips" {
  description = "The internal IP addresses of the Linux server instances"
  value       = [for instance in google_compute_instance.linux_server : instance.network_interface[0].network_ip]
}

# Output: External IP Addresses of Linux Server Instances
# Lists the external IP addresses assigned to each Linux server instance (if applicable)
output "linux_server_external_ips" {
  description = "The external IP addresses of the Linux server instances (if assigned)"
  value       = [for instance in google_compute_instance.linux_server : instance.network_interface[0].access_config[0].nat_ip]
}

# Output: Self-links of Linux Server Instances
# Provides the self-link URLs for each Linux server instance, used for GCP resource identification
output "linux_server_self_links" {
  description = "Self-links for Linux server instances"
  value       = [for instance in google_compute_instance.linux_server : instance.self_link]
}

# Output: Instance IDs of Linux Server Instances
# Returns a list of unique instance IDs for the Linux server instances, helpful for tracking and management
output "linux_server_instance_ids" {
  description = "List of Linux server instance IDs"
  value       = [for instance in google_compute_instance.linux_server : instance.id]
}
