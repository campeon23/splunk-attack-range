# -----------------------------------------------------------------------------
# Splunk Server Outputs
# These outputs provide essential information about the Splunk server instance,
# including the public IP address and the instance name. They can be used to 
# reference or verify the deployment in other modules or in deployment scripts.
# -----------------------------------------------------------------------------

# Output for the Public IP of the Splunk Server
output "splunk_server_ip" {
  description = "Public IP of the Splunk server instance in GCP"
  value       = google_compute_address.splunk_ip.address
}

# Output for the Name of the Splunk Server
output "splunk_server_name" {
  description = "Name of the Splunk server instance in GCP"
  value       = google_compute_instance.splunk_server.name
}
