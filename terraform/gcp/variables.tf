# -----------------------------------------------------------------------------
# Variable Definitions for Terraform Attack Range Deployment
# -----------------------------------------------------------------------------
# This file contains variable definitions used to deploy resources on Google Cloud
# Platform (GCP) for an attack range environment, including general configurations,
# instance-specific settings, and networking details. Each variable block defines
# default values and expected data types, allowing for flexibility and reusability
# across environments.
# -----------------------------------------------------------------------------

# General configuration settings for the attack range, including common parameters
variable "general" {
  description = "General configuration for the attack range"
  type = map(string)

  default = {
    attack_range_password   = "Pl3ase-k1Ll-me:p"  # Password for the attack range instances
    attack_range_name       = "attack-range-name" # Name identifier for the attack range
    key_name                = "attack-range-key-pair" # SSH key pair name
    ip_whitelist            = "0.0.0.0/0" # Whitelist IP range for open access
    cloud_provider          = "gcp" # Cloud provider, e.g., "gcp" or "aws"
    install_contentctl      = "1" # "1" to install content control tools, "0" to skip
  }
}

# Google Cloud Platform-specific configuration settings
variable "gcp" {
  description = "GCP configuration"
  type = map(string)

  default = {
    region                  = "us-central1" # GCP region
    zone                    = "us-central1-a" # GCP zone within the specified region
    project_id              = "your-gcp-project-id" # Replace with actual project ID
    public_key_path         = "~/.ssh/id_rsa.pub" # Path to SSH public key
    private_key_path        = "~/.ssh/id_rsa" # Path to SSH private key
    use_elastic_ips         = "0" # "1" to use elastic IPs, "0" otherwise
  }
}

# Network CIDR blocks for public and private subnets
variable "cidrs" {
  description = "Network configuration"
  type = map(any)

  default = {
    cidr_blocks = [
      "10.0.1.0/24", # Public subnet CIDR block
      "10.0.2.0/24"  # Private subnet CIDR block
    ]
  }
}

# Splunk server instance configuration settings
variable "splunk_server" {
  description = "Configuration for the Splunk server instance"
  type = object({
    hostname          = string # Hostname for the server instance
    machine_type      = string # Machine type, e.g., "e2-standard-4"
    image             = string # Image, e.g., "ubuntu-2204-lts"
    disk_size         = number # Disk size in GB
    disk_type         = string # Disk type, e.g., "pd-standard"
    install_es        = string # "1" to install Splunk Enterprise Security, "0" otherwise
    byo_splunk        = string # "1" for BYO Splunk, "0" otherwise
    splunk_es_app     = string # Splunk Enterprise Security app to install
    network_ip        = string # Static internal IP
    byo_splunk_ip     = string # BYO Splunk IP, if applicable
    splunk_url        = string # Splunk installation URL
    splunk_uf_url     = string # Splunk Universal Forwarder URL for Linux
    splunk_uf_win_url = string # Splunk Universal Forwarder URL for Windows
    s3_bucket_url     = string # URL for S3 bucket containing Splunk apps
    splunk_apps       = string # Comma-separated list of Splunk apps to install
  })

  default = {
    hostname          = "splunk"
    machine_type      = "e2-standard-4"
    image             = "ubuntu-2204-lts"
    disk_type         = "pd-standard"
    disk_size         = 120
    install_es        = "1"
    byo_splunk        = "1"
    splunk_es_app     = "splunk-enterprise-security_701.spl"
    network_ip        = "10.0.2.220"
    byo_splunk_ip     = ""
    splunk_url        = "https://download.splunk.com/products/splunk/releases/9.3.0/linux/splunk-9.3.0-51ccf43db5bd-Linux-x86_64.tgz"
    splunk_uf_url     = "https://download.splunk.com/products/universalforwarder/releases/9.3.0/linux/splunkforwarder-9.3.0-51ccf43db5bd-linux-2.6-amd64.deb"
    splunk_uf_win_url = "https://download.splunk.com/products/universalforwarder/releases/9.3.0/windows/splunkforwarder-9.3.0-51ccf43db5bd-x64-release.msi"
    s3_bucket_url     = "https://attack-range-appbinaries.s3-us-west-2.amazonaws.com"
    splunk_apps       = "TA-aurora-0.2.0.tar.gz,TA-osquery.tar.gz,app-for-circleci_011.tgz,..."
  }
}

# Configuration for Phantom server instance
variable "phantom_server" {
  description = "Phantom server configuration"
  type = object({
    phantom_server = number # "1" if enabled, "0" otherwise
    hostname       = string # Phantom server hostname
    machine_type   = string # Machine type, e.g., "e2-standard-4"
    image          = string # Image, e.g., "centos-cloud/centos-7"
    disk_size      = number # Disk size in GB
    disk_type      = string # Disk type, e.g., "pd-standard"
    network_ip     = string # Internal IP for the instance
    phantom_app    = string # Name of the Phantom application to install
  })

  default = {
    phantom_server = "1"
    hostname       = "phantom"
    machine_type   = "e2-standard-4"
    image          = "centos-cloud/centos-7"
    disk_type      = "pd-standard"
    disk_size      = 30
    network_ip     = "10.0.2.5"
    phantom_app    = "splunk_soar-unpriv-6.3.0.719-d9df3cc1-el8-x86_64.tgz"
  }
}

# Configuration for NGINX server instance
variable "nginx_server" {
  description = "Nginx server configuration"
  type = object({
    nginx_server      = number # "1" if enabled, "0" otherwise
    hostname          = string # Hostname for NGINX server
    machine_type      = string # Machine type, e.g., "e2-small"
    image             = string # Image, e.g., "ubuntu-2204-lts"
    disk_size         = number # Disk size in GB
    disk_type         = string # Disk type, e.g., "pd-standard"
    network_ip        = string # Static internal IP
    proxy_server_ip   = string # IP of proxy server, if applicable
    proxy_server_port = string # Port for proxy server, if applicable
  })

  default = {
    nginx_server      = "1"
    hostname          = "nginx"
    machine_type      = "e2-small"
    image             = "ubuntu-2204-lts"
    disk_type         = "pd-standard"
    disk_size         = 20
    network_ip        = "10.0.2.31"
    proxy_server_ip   = "10.0.2.254"
    proxy_server_port = "8000"
  }
}

# Configuration for Kali Linux server instance
variable "kali_server" {
  description = "Kali Linux server configuration"
  type = object({
    kali_server   = number # "1" if enabled, "0" otherwise
    hostname      = string # Hostname for Kali Linux server
    machine_type  = string # Machine type, e.g., "e2-standard-2"
    image         = string # Image, e.g., "kali-linux-image"
    disk_size     = number # Disk size in GB
    disk_type     = string # Disk type, e.g., "pd-ssd"
    network_ip    = string # Static internal IP
  })

  default = {
    kali_server   = 1
    hostname      = "kali"
    machine_type  = "e2-standard-2"
    image         = "kali-linux-image"
    disk_size     = 30
    disk_type     = "pd-ssd"
    network_ip    = "10.0.2.30"
  }
}

# List of Linux server instance configurations
variable "linux_servers" {
  description = "List of configurations for each Linux server instance"
  type = list(object({
    machine_type            = string  # Instance machine type, e.g., "e2-standard-4"
    image                   = string  # Image, e.g., "ubuntu-2204-lts"
    disk_size               = number  # Boot disk size in GB
    disk_type               = string  # Disk type, e.g., "pd-standard" or "pd-ssd"
    hostname                = string  # Hostname for the Linux server instance
    splunk_uf_url           = string  # Splunk Universal Forwarder download URL
    sysmon_config           = string  # Sysmon configuration file name
    install_crowdstrike     = string  # "1" to install CrowdStrike, "0" otherwise
    crowdstrike_linux_agent = string # CrowdStrike Linux agent file name
  }))

  default = [
    {
      machine_type            = "e2-standard-4"
      image                   = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2204-lts"
      disk_type               = "pd-standard"
      disk_size               = 60
      hostname                = "ar-linux"
      splunk_uf_url           = "https://download.splunk.com/products/universalforwarder/releases/9.3.0/linux/splunkforwarder-9.3.0-51ccf43db5bd-linux-2.6-amd64.deb"
      sysmon_config           = "SwiftOnSecurity.xml"
      install_crowdstrike     = "1"
      crowdstrike_linux_agent = "falcon-sensor_7.18.0-17106_amd64.deb"
    }
  ]
}

# Configuration for Windows servers
variable "windows_servers" {
  description = "Configuration for Windows servers"
  type = list(object({
    hostname                = string # Hostname for the Windows server
    image                   = string # Image, e.g., "windows-2019"
    machine_type            = string # Machine type, e.g., "n2-standard-4"
    disk_size               = number # Disk size in GB
    disk_type               = string # Disk type, e.g., "pd-ssd"
    win_sysmon_config       = string # Sysmon configuration file
    create_domain           = string # "1" to create domain, "0" otherwise
    join_domain             = string # "1" to join domain, "0" otherwise
    install_red_team_tools  = string # "1" to install red team tools, "0" otherwise
    advanced_logging        = string # "1" to enable advanced logging, "0" otherwise
    splunk_uf_win_url       = string # Splunk Universal Forwarder for Windows URL
  }))

  default = [
    {
      hostname                = "ar-win"
      image                   = "projects/windows-cloud/global/images/family/windows-2019"
      machine_type            = "n2-standard-4"
      disk_type               = "pd-ssd"
      disk_size               = 50
      win_sysmon_config       = "SwiftOnSecurity.xml"
      create_domain           = "0"
      join_domain             = "0"
      install_red_team_tools  = "0"
      advanced_logging        = "1"
      splunk_uf_win_url       = "https://download.splunk.com/products/universalforwarder/releases/9.3.0/windows/splunkforwarder-9.3.0-51ccf43db5bd-x64-release.msi"
    }
  ]
}

# Placeholder variables for Snort and Zeek servers and simulation settings
variable "zeek_server" { }

variable "snort_server" { }

variable "simulation" { }
