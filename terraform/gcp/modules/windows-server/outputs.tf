# -----------------------------------------------------------------------------
# Windows Server Output Variables
# -----------------------------------------------------------------------------
# These outputs provide details about the deployed Windows server instances,
# including their names, internal and external IP addresses, and instance IDs.
# -----------------------------------------------------------------------------

# Output the names of the Windows server instances
output "windows_server_names" {
  description = "Names of the Windows server instances"
  value       = [for instance in google_compute_instance.windows_server : instance.name]
}

# Output the internal IP addresses of the Windows server instances
output "windows_server_internal_ips" {
  description = "Internal IP addresses of the Windows server instances"
  value       = [for instance in google_compute_instance.windows_server : instance.network_interface[0].network_ip]
}

# Output the external IP addresses of the Windows server instances
# These are NAT IPs assigned to allow external access if configured.
output "windows_server_external_ips" {
  description = "External IP addresses of the Windows server instances"
  value       = [for instance in google_compute_instance.windows_server : instance.network_interface[0].access_config[0].nat_ip]
}

# Output the unique instance IDs for each Windows server instance
# Instance IDs are unique identifiers assigned by GCP.
output "windows_server_instance_ids" {
  description = "Instance IDs of the Windows server instances"
  value       = [for instance in google_compute_instance.windows_server : instance.id]
}
