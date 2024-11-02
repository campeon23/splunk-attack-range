# -----------------------------------------------------------------------------
# Output Variables for NGINX Server Instance
# These outputs provide essential details about the NGINX server instance,
# including its name, IP addresses, and self-link within Google Cloud Platform.
# -----------------------------------------------------------------------------

# Output: NGINX Server Instance Name
# Provides the name of the NGINX server instance for identification.
output "nginx_server_name" {
  description = "The name of the NGINX server instance"
  value       = google_compute_instance.nginx_server[*].name
}

# Output: Internal IP of NGINX Server Instance
# Provides the internal IP address, useful for private network communications.
output "nginx_server_internal_ip" {
  description = "The internal IP address of the NGINX server instance"
  value       = google_compute_instance.nginx_server[*].network_interface[0].network_ip
}

# Output: External IP of NGINX Server Instance
# Provides the external IP address, if assigned, allowing access from the internet.
output "nginx_server_external_ip" {
  description = "The external IP address of the NGINX server instance, if assigned"
  value       = google_compute_instance.nginx_server[*].network_interface[0].access_config[0].nat_ip
}

# Output: Self-Link of NGINX Server Instance
# Provides the self-link of the NGINX server, a URL uniquely identifying this instance in GCP.
output "nginx_server_self_link" {
  description = "The self-link of the NGINX server instance"
  value       = google_compute_instance.nginx_server[*].self_link
}
