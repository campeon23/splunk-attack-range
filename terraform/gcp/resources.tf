# Load network module to set up the VPC network and associated resources.
module "networkModule" {
  source  = "./modules/network"
  general = var.general                   # General project variables
  gcp     = var.gcp                       # GCP-specific project settings
  cidrs   = var.cidrs                     # CIDR blocks for network subnets
}

# IAM module to create and manage service accounts with appropriate roles.
module "iam" {
  source            = "./modules/iam"
  general           = var.general
  gcp               = var.gcp
  service_accounts  = var.service_accounts
}
# Splunk Server module to deploy and configure Splunk server on GCP.
module "splunk_server" {
  source = "./modules/splunk-server"
  vpc_network = module.networkModule.vpc_network_id
  subnetwork = module.networkModule.vpc_public_subnet_id

  # General configuration
  gcp = var.gcp
  general = var.general
  service_accounts = var.service_accounts
  splunk_sa_email = module.iam.service_account_emails["splunk"]
  splunk_sa_roles = module.iam.assigned_roles["splunk"]

  # Server instances and dependencies
  splunk_server = var.splunk_server
  phantom_server = var.phantom_server
  kali_server = var.kali_server
  snort_server = var.snort_server
  zeek_server = var.zeek_server
  windows_servers = var.windows_servers
  linux_servers = var.linux_servers
  simulation = var.simulation
}

# Phantom Server module to deploy Phantom server and configure network/security settings.
module "phantom-server" {
  source               = "./modules/phantom-server"

  # Network configuration (GCP equivalent of VPC and subnet IDs)
  vpc_network          = module.networkModule.vpc_network_id        
  subnetwork           = module.networkModule.vpc_public_subnet_id  
  cidrs                = var.cidrs

  # General configuration
  general              = var.general                                
  gcp                  = var.gcp                                    
  service_accounts     = var.service_accounts
  phantom_sa_email     = module.iam.service_account_emails["phantom"]
  phantom_sa_roles     = module.iam.assigned_roles["phantom"]

  # Server instances and dependencies
  splunk_server        = var.splunk_server                          
  phantom_server       = var.phantom_server                   
}

# NGINX Server module to deploy and manage an NGINX server.
module "nginx_server" {
  source               = "./modules/nginx-server"

  # Network configuration (GCP equivalent of VPC and subnet IDs)
  vpc_network          = module.networkModule.vpc_network_id  
  subnetwork           = module.networkModule.vpc_public_subnet_id 
  cidrs                = var.cidrs

  # General configuration
  general              = var.general
  gcp                  = var.gcp
  service_accounts     = var.service_accounts
  nginx_sa_email       = module.iam.service_account_emails["nginx"]
  nginx_sa_roles       = module.iam.assigned_roles["nginx"]

  # Server instances and dependencies
  splunk_server        = var.splunk_server
  nginx_server         = var.nginx_server
}

# Kali Server module to deploy Kali Linux for security assessments and network tests.
module "kali-server" {
  source              = "./modules/kali-server"
  vpc_network         = module.networkModule.vpc_network_id 
  subnetwork          = module.networkModule.vpc_public_subnet_id 
  cidrs               = var.cidrs
  general             = var.general
  kali_server         = var.kali_server
  gcp                 = var.gcp
  service_accounts    = var.service_accounts
  kali_sa_email       = module.iam.service_account_emails["kali"]
  kali_sa_roles       = module.iam.assigned_roles["kali"]
}

# Linux Server module to deploy and configure Linux servers.
module "linux_server" {
  source                = "./modules/linux-server"

  # Network configuration (GCP equivalent of VPC and subnet IDs)
  vpc_network           = module.networkModule.vpc_network_id
  subnetwork            = module.networkModule.vpc_public_subnet_id
  cidrs                 = var.cidrs 

  # General configuration
  general               = var.general
  gcp                   = var.gcp
  service_accounts      = var.service_accounts
  linux_sa_email        = module.iam.service_account_emails["linux"]
  linux_sa_roles        = module.iam.assigned_roles["linux"]
  
  # Server instances and dependencies
  splunk_server         = var.splunk_server
  snort_server          = var.snort_server
  zeek_server           = var.zeek_server
  linux_servers         = var.linux_servers

  simulation            = var.simulation
}

# Windows Server module to deploy and configure Windows servers.
module "windows_server" {
  source                  = "./modules/windows-server"

  # Network configuration (GCP equivalent of VPC and subnet IDs)
  vpc_network             = module.networkModule.vpc_network_id 
  subnetwork              = module.networkModule.vpc_public_subnet_id
  
  # General configuration
  general                 = var.general
  gcp                     = var.gcp
  service_accounts        = var.service_accounts
  windows_sa_email        = module.iam.service_account_emails["windows"]
  windows_sa_roles        = module.iam.assigned_roles["windows"]
  
  # Server instances and dependencies
  splunk_server           = var.splunk_server
  snort_server            = var.snort_server
  zeek_server             = var.zeek_server
  windows_servers         = var.windows_servers

  simulation              = var.simulation 
}

# Snort Server module to deploy a Snort instance for network intrusion detection.
module "snort_server" {
  source = "./modules/snort-server"

  # Network configuration (GCP equivalent of VPC and subnet IDs)
  vpc_network          = module.networkModule.vpc_network_id
  subnetwork           = module.networkModule.vpc_public_subnet_id
  cidrs                = var.cidrs

  # General configuration
  general              = var.general
  gcp                  = var.gcp
  service_accounts     = var.service_accounts
  snort_sa_email       = module.iam.service_account_emails["snort"]
  snort_sa_roles       = module.iam.assigned_roles["snort"]
  
  # Server instances and dependencies
  splunk_server            = var.splunk_server
  snort_server             = var.snort_server
  windows_servers          = var.windows_servers
  windows_server_instances = module.windows_server.windows_server_instance_ids
  linux_servers            = var.linux_servers
  linux_server_instances   = module.linux_server.linux_server_instance_ids
}

# Zeek Server module to deploy and configure Zeek for network monitoring.
module "zeek_server" {
  source                          = "./modules/zeek-server"

  # Network configuration (GCP equivalent of VPC and subnet IDs)
  vpc_network                     = module.networkModule.vpc_network_id  
  subnetwork                      = module.networkModule.vpc_public_subnet_id 
  cidrs                           = var.cidrs 

  # General configuration
  general                         = var.general
  gcp                             = var.gcp
  service_accounts                = var.service_accounts
  zeek_sa_email                   = module.iam.service_account_emails["zeek"]
  zeek_sa_roles                   = module.iam.assigned_roles["zeek"]
  
  # Server instances and dependencies
  splunk_server                   = var.splunk_server
  snort_server                    = var.snort_server
  zeek_server                     = var.zeek_server
  windows_servers                 = var.windows_servers
  windows_server_instances        = module.windows_server.windows_server_instance_ids 
  linux_servers                   = var.linux_servers
  linux_server_instances          = module.linux_server.linux_server_instance_ids
  
  # 
  snort_sensor_self_links         = module.snort_server.snort_server_self_links
  snort_forwarding_rule_self_link = module.snort_server.snort_forwarding_rule_self_link
  snort_backend_service_self_link = module.snort_server.snort_backend_service_self_link
}
