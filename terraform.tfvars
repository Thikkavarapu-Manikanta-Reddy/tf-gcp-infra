credentials_file = "/Users/manikantareddythikkavarapu/Documents/NEU/Sem 3/Network Struc & Cloud Comp NEU Course/MANI/tf-gcp-infra/csye6255-assignment-3-414221-57846f52447e.json"
project          = "csye6255-assignment-3-414221"

num_vpcs = 3

region                                   = "us-east1"
zone                                     = "us-east1-c"
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
allowed_port_list   = [80, 8080, 22, 443]
allow_protocol      = "tcp"
deny_protocol       = "all"
deny_ports          = []

vm_instance_name         = "my-vm-instance"
vm_instance_zone         = "us-east1-c"
vm_instance_machine_type = "e2-medium"
vm_instance_image        = "projects/csye6255-assignment-3-414221/global/images/centos-image"
vm_instance_disk_type    = "pd-balanced"
vm_instance_disk_size_gb = 30

firewall_src_range           = ["0.0.0.0/0"]
vm_tag                       = ["my-vm-tag"]
allow_firewall_rule_priority = 699

database_instance_tier = "db-g1-small"

mailgun_api_key     = "8915af05b13d1904c9f8d8595a2c45cc-4c205c86-c0afbd2d"
mailgun_domain_name = "mg.manikantareddythikkavarapu.me"

eventtrigger_retry_policy                    = "RETRY_POLICY_RETRY"
cloudfunction_ingress_settings               = "ALLOW_INTERNAL_ONLY"
cloudfunction_all_traffic_on_latest_revision = true
vpc_connector_egress_settings                = "PRIVATE_RANGES_ONLY"
max_instance_count                           = 1
min_instance_count                           = 0
available_memory                             = "256M"
timeout_seconds                              = 60
cloudfunction_account_id                     = "function-sa"
cloudfunction_display_name                   = "Function Service Account"
pubsub_subscription_name                     = "verify_email_subscription"
ack_deadline_seconds                         = 10
ttl                                          = "604800s"

template_tags                                = ["load-balanced-backend", "webapp"]
http_named_port_name                         = "http"
http_named_port_port                         = 8080
base_instance_name                           = "my-custom-vm"
instance_grp_target_size                     = 2
auto_healing_policies_initial_delay_sec      = 300

autoscaler_name        = "my-auto-scaler"
max_replicas           = 2
min_replicas           = 1
cooldown_period        = 60
target_cpu_utilization = 0.05

reserved_ip_address_name            = "load-balancer-ipv4-address"
http_health_check_name              = "http-health-check"
health_check_request_path           = "/healthz"
loadbalancer_backend_service_name   = "load-balancer-backend-service"
loadbalancer_protocol_name          = "HTTP"
load_balancing_scheme               = "EXTERNAL"
loadbalancer_backend_balancing_mode = "UTILIZATION"

compute_url_map_name = "my-url-map"

webapp_ssl_cert_name            = "webapp-ssl-cert"
ssl_certificate_managed_domains = ["manikantareddythikkavarapu.me"]

loadbalancer_proxy_name = "load-balancer-proxy"

forwarding_rule_name                  = "https-forwarding-rule"
forwarding_rule_ip_protocol           = "TCP"
forwarding_rule_load_balancing_scheme = "EXTERNAL"
forwarding_rule_port_range            = "443"

allow_rule_target_tag = ["webapp"]

allow_rule_health_check_name          = "fw-allow-health-check"
allow_rule_health_check_protocol      = "tcp"
allow_rule_health_check_direction     = "INGRESS"
allow_rule_health_check_source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
allow_rule_health_check_target_tags   = ["load-balanced-backend", "webapp"]

allow_lb_firewall_name              = "allow-lb-firewall"
allow_lb_firewall_protocol          = "tcp"
allow_lb_firewall_ports             = ["8080", "443"]
allow_lb_firewall_source_ranges     = ["130.211.0.0/22", "35.191.0.0/16"]
allow_lb_firewall_source_tags       = ["webapp"]
cloudsql_crypto_key_name            = "cloudsql-crypto-key"
cloudsql_crypto_key_rotation_period = "2592000s"
cloudsql_service_identity           = "sqladmin.googleapis.com"
vm_crypto_key_name                  = "vm-crypto-key"
vm_crypto_key_rotation_period       = "2592000s"

vm_crypto_key_members              = ["serviceAccount:service-812322576877@compute-system.iam.gserviceaccount.com"]
storage_crypto_key_name            = "storage-crypto-key"
storage_crypto_key_rotation_period = "2592000s"

vm_service_account_display_name = "VM Service Account"
vm_service_account_account_id   = "vm-instance-service-account"