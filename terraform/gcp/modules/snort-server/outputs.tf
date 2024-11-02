# --------------------------------------------------------------------------
# Snort Server Output Variables
# These output variables provide key information about the Snort server 
# instance, including its name, IP addresses, self-links, and associated 
# network configurations. These outputs allow easy access to essential 
# attributes of the Snort instance and related GCP resources.
# --------------------------------------------------------------------------

# Output: Snort Server Instance Name
output "snort_server_name" {
  description = "The name of the Snort server instance"
  value       = google_compute_instance.snort_sensor[*].name
}

# Output: Snort Server Internal IP Address
output "snort_server_internal_ip" {
  description = "The internal IP address of the Snort server instance"
  value       = google_compute_instance.snort_sensor[*].network_interface[0].network_ip
}

# Output: Snort Server External IP Address
output "snort_server_external_ip" {
  description = "The external IP address of the Snort server instance, if assigned"
  value       = google_compute_instance.snort_sensor[*].network_interface[0].access_config[0].nat_ip
}

# Output: Self-Link for Snort Sensor Instances
output "snort_server_self_links" {
  description = "Self-links for Snort sensor instances"
  value       = google_compute_instance.snort_sensor[*].self_link
}

# --------------------------------------------------------------------------
# Snort Server Network Configuration Outputs
# Outputs for key network resources associated with the Snort instance,
# including forwarding rules and backend services, to support network 
# traffic monitoring and forwarding.
# --------------------------------------------------------------------------

# Output: Self-Link for Snort Forwarding Rule
output "snort_forwarding_rule_self_link" {
  description = "Self-link for the Snort forwarding rule, directing mirrored traffic"
  value       = google_compute_forwarding_rule.snort_forwarding_rule.self_link
}

# Output: Self-Link for Snort Backend Service
output "snort_backend_service_self_link" {
  description = "Self-link for the Snort backend service, used in packet mirroring"
  value       = google_compute_region_backend_service.snort_backend_service.self_link
}
