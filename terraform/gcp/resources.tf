module "networkModule" {
  source               = "./modules/network"
  general              = var.general
  gcp                  = var.gcp
  cidrs                = var.cidrs
}

module "splunk_server" {
  source               = "./modules/splunk-server"
  
  # Pass the VPC network and subnet from the GCP network module
  vpc_network          = module.networkModule.vpc_network_id
  subnetwork           = module.networkModule.vpc_public_subnet_id  # Using the public subnet for public access

  # Pass in GCP-specific configurations
  gcp                  = var.gcp
  general              = var.general

  # Module-specific variables
  splunk_server        = var.splunk_server
  phantom_server       = var.phantom_server
  kali_server          = var.kali_server
  snort_server         = var.snort_server
  zeek_server          = var.zeek_server
  windows_servers      = var.windows_servers
  linux_servers        = var.linux_servers

  simulation           = var.simulation
}

module "phantom-server" {
  source               = "./modules/phantom-server"

  # Network configuration (GCP equivalent of VPC and subnet IDs)
  vpc_network          = module.networkModule.vpc_network_id        # GCP's equivalent of `vpc_security_group_ids` for network
  subnetwork           = module.networkModule.vpc_public_subnet_id  # GCP's equivalent of `ec2_subnet_id` for subnet
  cidrs                = var.cidrs

  # General configuration
  general              = var.general                                # General configuration variables
  gcp                  = var.gcp                                    # GCP-specific settings like zone and SSH keys

  # Server instances and dependencies
  splunk_server        = var.splunk_server                          # Splunk server info for Ansible if needed
  phantom_server       = var.phantom_server                         # Phantom server settings
}

module "nginx_server" {
  source               = "./modules/nginx-server"

  # Network configuration (GCP equivalent of VPC and subnet IDs)
  vpc_network          = module.networkModule.vpc_network_id      # Reference the network module’s VPC network
  subnetwork           = module.networkModule.vpc_public_subnet_id  # Reference the network module’s subnet
  cidrs                = var.cidrs

  # General configuration
  general              = var.general
  gcp                  = var.gcp
  
  # Server instances and dependencies
  splunk_server        = var.splunk_server
  nginx_server         = var.nginx_server
}

module "kali-server" {
  source               = "./modules/kali-server"
  vpc_network          = module.networkModule.vpc_network_id      # Reference the network module’s VPC network
  subnetwork           = module.networkModule.vpc_public_subnet_id  # Reference the network module’s subnet
  cidrs                = var.cidrs
  general              = var.general
  kali_server          = var.kali_server
  gcp                  = var.gcp
}


module "linux_server" {
  source               = "./modules/linux-server"

  # Network configuration (GCP equivalent of VPC and subnet IDs)
  vpc_network          = module.networkModule.vpc_network_id
  subnetwork           = module.networkModule.vpc_public_subnet_id
  cidrs                = var.cidrs 

  # General configuration
  general              = var.general
  gcp                  = var.gcp
  
  # Server instances and dependencies
  splunk_server        = var.splunk_server
  snort_server         = var.snort_server
  zeek_server          = var.zeek_server
  linux_servers        = var.linux_servers

  simulation           = var.simulation
}

module "windows_server" {
  source               = "./modules/windows-server"

  # Network configuration (GCP equivalent of VPC and subnet IDs)
  vpc_network          = module.networkModule.vpc_network_id       # GCP VPC network
  subnetwork           = module.networkModule.vpc_public_subnet_id # GCP subnet
  
  # General configuration
  general              = var.general                               # General configuration
  gcp                  = var.gcp                                   # GCP project configuration
  
  # Server instances and dependencies
  splunk_server        = var.splunk_server                         # Splunk server configuration
  snort_server         = var.snort_server                          # Snort server configuration
  zeek_server          = var.zeek_server                           # Zeek server configuration
  windows_servers      = var.windows_servers                       # Windows server configuration (list of instances)

  simulation           = var.simulation                            # Simulation configuration if needed
}

module "snort_server" {
  source = "./modules/snort-server"

  # Network configuration (GCP equivalent of VPC and subnet IDs)
  vpc_network          = module.networkModule.vpc_network_id     # Replace with the output for VPC network name from network module
  subnetwork           = module.networkModule.vpc_public_subnet_id # Replace with the output for subnet name from network module
  cidrs                = var.cidrs

  # General configuration
  general              = var.general
  gcp                  = var.gcp  # GCP-specific configuration (instead of `aws`)
  
  # Server instances and dependencies
  splunk_server            = var.splunk_server
  snort_server             = var.snort_server
  windows_servers          = var.windows_servers
  windows_server_instances = module.windows_server.windows_server_instance_ids
  linux_servers            = var.linux_servers
  linux_server_instances   = module.linux_server.linux_server_instance_ids
}

module "zeek_server" {
  source                          = "./modules/zeek-server"

  # Network configuration (GCP equivalent of VPC and subnet IDs)
  vpc_network                     = module.networkModule.vpc_network_id                 # GCP VPC network name
  subnetwork                      = module.networkModule.vpc_public_subnet_id           # GCP subnet name
  cidrs                           = var.cidrs                                           # CIDR blocks for the network

  # General configuration
  general                         = var.general                                         # General configuration
  gcp                             = var.gcp                                             # GCP project configuration
  
  # Server instances and dependencies
  splunk_server                   = var.splunk_server                                   # Splunk server configurations
  snort_server                    = var.snort_server                                    # Snort server configurations
  zeek_server                     = var.zeek_server                                     # Zeek server configurations (instance type, image, etc.)
  windows_servers                 = var.windows_servers                                 # List of Windows servers for packet mirroring
  windows_server_instances        = module.windows_server.windows_server_instance_ids   # Reference to Windows server instances
  linux_servers                   = var.linux_servers                                   # List of Linux servers for packet mirroring
  linux_server_instances          = module.linux_server.linux_server_instance_ids       # Reference to Linux server instances
  
  # 
  snort_sensor_self_links         = module.snort_server.snort_server_self_links         # Snort sensor self links
  snort_forwarding_rule_self_link = module.snort_server.snort_forwarding_rule_self_link # Snort forwarding rule self link
  snort_backend_service_self_link = module.snort_server.snort_backend_service_self_link # Snort backend service self link
}
