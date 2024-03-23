resource "google_compute_network" "vpc_network" {
  # count                           = var.num_vpcs
  name                            = "${var.vpc_name}-${uuid()}"
  auto_create_subnetworks         = var.vpc_auto_create_subnetworks_false
  routing_mode                    = var.vpc_routing_mode_regional
  delete_default_routes_on_create = var.vpc_delete_default_routes_on_create_true
}

resource "google_compute_subnetwork" "webapp" {
  # count         = var.num_vpcs
  # name          = count.index == 0 ? var.public_subnet_name : "${var.public_subnet_name}-${uuid()}"
  name                     = var.public_subnet_name
  ip_cidr_range            = var.webapp_cidr_range
  region                   = var.region
  network                  = google_compute_network.vpc_network.name
  private_ip_google_access = var.subnet_webapp_private_ip_google_access
}

resource "google_compute_subnetwork" "db" {
  # count         = var.num_vpcs
  # name          = count.index == 0 ? var.private_subnet_name : "${var.private_subnet_name}-${uuid()}"
  name          = var.private_subnet_name
  ip_cidr_range = var.db_cidr_range
  region        = var.region
  network       = google_compute_network.vpc_network.name
}

resource "google_compute_route" "internet_gateway_route" {
  # count            = var.num_vpcs
  name             = "${var.route_name}-${uuid()}"
  depends_on       = [google_compute_subnetwork.webapp]
  dest_range       = var.webapp_internet_gateway_route_dest
  network          = google_compute_network.vpc_network.name
  next_hop_gateway = var.webapp_internet_gateway_route_next_hop_gateway
  priority         = var.internet_gateway_route_priority
}

resource "google_compute_firewall" "allow_rule" {
  name        = var.allow_firewall_name
  network     = google_compute_network.vpc_network.name
  source_tags = var.vm_tag
  target_tags = var.vm_tag
  allow {
    protocol = var.allow_protocol
    ports    = var.allowed_port_list
  }

  source_ranges = var.firewall_src_range
  priority      = var.allow_firewall_rule_priority
}

resource "google_compute_firewall" "deny_rule" {
  name    = var.deny_firewall_name
  network = google_compute_network.vpc_network.name

  deny {
    protocol = var.deny_protocol
  }

  source_ranges = var.firewall_src_range
}

resource "google_compute_instance" "custom_vm_instance" {
  name         = var.vm_instance_name
  zone         = var.vm_instance_zone
  machine_type = var.vm_instance_machine_type
  tags         = var.vm_tag
  depends_on   = [google_service_account.vm_service_account, google_sql_database_instance.main_primary]
  boot_disk {
    initialize_params {
      image = var.vm_instance_image
      type  = var.vm_instance_disk_type
      size  = var.vm_instance_disk_size_gb
    }
  }

  network_interface {
    network    = google_compute_network.vpc_network.name
    subnetwork = google_compute_subnetwork.webapp.self_link

    access_config {
      // Assigns a public IP address
    }
  }
  metadata_startup_script = templatefile("scripts/startup.sh", {
    DB_INTERNAL_IP_ADDRESS = "${google_sql_database_instance.main_primary.private_ip_address}",
    DB_USERNAME            = var.google_sql_user_webapp_name,
    DB_PASSWORD            = "${random_password.password.result}",
    DB_NAME                = var.google_sql_database_webapp_name,
    location               = var.properties_location
  })
  service_account {
    email  = google_service_account.vm_service_account.email
    scopes = ["cloud-platform"]
  }
}

resource "google_service_account" "vm_service_account" {
  account_id   = "vm-instance-service-account"
  display_name = "VM Service Account"
  # create_ignore_already_exists = true
}

resource "google_project_iam_binding" "logging_roles_binding" {
  project = var.projectId

  role = "roles/logging.admin"

  members = [
    "serviceAccount:${google_service_account.vm_service_account.email}",
  ]
  depends_on = [google_service_account.vm_service_account]
}

resource "google_project_iam_binding" "metric_roles_binding" {
  project = var.projectId

  role = "roles/monitoring.metricWriter"

  members = [
    "serviceAccount:${google_service_account.vm_service_account.email}",
  ]

  depends_on = [google_service_account.vm_service_account]
}

# Create a private address range for our network
resource "google_compute_global_address" "private_ip_block" {
  name          = var.private_ip_block_name
  purpose       = var.private_ip_block_purpose
  address_type  = var.private_ip_block_address_type
  ip_version    = var.private_ip_block_ip_version
  prefix_length = var.private_ip_block_prefix_length
  network       = google_compute_network.vpc_network.self_link
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc_network.self_link
  service                 = var.private_vpc_connection_service
  reserved_peering_ranges = [google_compute_global_address.private_ip_block.name]
}

resource "google_sql_database" "webapp" {
  name     = var.google_sql_database_webapp_name
  instance = google_sql_database_instance.main_primary.name
}
resource "google_sql_database_instance" "main_primary" {
  name             = var.sql_instance_name
  database_version = var.database_version
  region           = var.region
  depends_on       = [google_service_networking_connection.private_vpc_connection]
  settings {
    tier              = var.database_instance_tier
    availability_type = var.database_instance_availability_type
    disk_size         = var.database_instance_disk_size
    disk_type         = var.database_instance_disk_type
    ip_configuration {
      ipv4_enabled    = var.database_instance_IPV4_enabled
      private_network = google_compute_network.vpc_network.self_link
    }
    backup_configuration {
      enabled            = var.backup_configuration_enabled
      binary_log_enabled = var.backup_configuration_binary_log_enabled
    }
  }
  deletion_protection = var.database_instance_deletion_protection
}

resource "random_password" "password" {
  length  = var.password_restriction_length
  special = var.password_restriction_special_characters_allowed
  # override_special = var.password_restriction_override_special
}

resource "google_sql_user" "db_user" {
  name     = var.google_sql_user_webapp_name
  instance = google_sql_database_instance.main_primary.name
  password = random_password.password.result
}

data "google_dns_managed_zone" "env_dns_zone" {
  name = "manikanta-reddy-thikkavarapu"
}

resource "google_dns_record_set" "a_dns_record" {
  name         = data.google_dns_managed_zone.env_dns_zone.dns_name
  managed_zone = data.google_dns_managed_zone.env_dns_zone.name
  type         = "A"
  ttl          = 60
  rrdatas = [
    google_compute_instance.custom_vm_instance.network_interface[0].access_config[0].nat_ip
  ]

  depends_on = [google_compute_instance.custom_vm_instance]
}