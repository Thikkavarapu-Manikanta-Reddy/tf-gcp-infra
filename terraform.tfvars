credentials_file = "/Users/manikantareddythikkavarapu/Documents/NEU/Sem 3/Network Struc & Cloud Comp NEU Course/MANI/tf-gcp-infra/csye6255-assignment-3-414221-57846f52447e.json"
project          = "csye6255-assignment-3-414221"

num_vpcs = 3

region                                   = "us-central1"
zone                                     = "us-central1-c"
vpc_name                                 = "terraform-network"
vpc_auto_create_subnetworks_false        = false
vpc_routing_mode_regional                = "REGIONAL"
vpc_delete_default_routes_on_create_true = true

public_subnet_name = "webapp"

private_subnet_name                            = "db"
webapp_cidr_range                              = "10.0.1.0/24"
db_cidr_range                                  = "10.0.2.0/24"
route_name                                     = "internet-gateway-route"
webapp_internet_gateway_route_dest             = "0.0.0.0/0"
webapp_internet_gateway_route_next_hop_gateway = "default-internet-gateway"
internet_gateway_route_priority                = 2000

allow_firewall_name = "my-firewall-allow-8080"
deny_firewall_name  = "ssh-deny-firewall-rule"
allowed_port_list   = [80, 8080, 22]
allow_protocol      = "tcp"
deny_protocol       = "all"
deny_ports          = []

vm_instance_name         = "my-vm-instance"
vm_instance_zone         = "us-central1-c"
vm_instance_machine_type = "e2-medium"
vm_instance_image        = "projects/csye6255-assignment-3-414221/global/images/centos-image"
vm_instance_disk_type    = "pd-balanced"
vm_instance_disk_size_gb = 100

firewall_src_range           = ["0.0.0.0/0"]
vm_tag                       = ["my-vm-tag"]
allow_firewall_rule_priority = 699

database_instance_tier = "db-g1-small"

mailgun_api_key="f68a26c9-d0641728"
mailgun_domain_name="sandboxbd0ad96e77b74f7fb6219b3f816c92e1.mailgun.org"