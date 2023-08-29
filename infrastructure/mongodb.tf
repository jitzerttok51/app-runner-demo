resource "mongodbatlas_project" "atlas-project" {
  org_id = "64e7a3a5f26f904083be0bba"
  name   = "myFirstProject"
}

resource "random_password" "db-user-password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "mongodbatlas_database_user" "db-user" {
  username           = "user-1"
  password           = random_password.db-user-password.result
  project_id         = mongodbatlas_project.atlas-project.id
  auth_database_name = "admin"
  roles {
    role_name     = "readWrite"
    database_name = "${mongodbatlas_project.atlas-project.name}-db"
  }
}

# data "http" "myip" {
#   url = "http://ipv4.icanhazip.com"
# }

# resource "mongodbatlas_project_ip_access_list" "ip" {
#   project_id = mongodbatlas_project.atlas-project.id
#   ip_address = "${chomp(data.http.myip.body)}"
# }

resource "mongodbatlas_advanced_cluster" "atlas-cluster" {
  paused       = var.pause-services
  project_id   = mongodbatlas_project.atlas-project.id
  name         = "${mongodbatlas_project.atlas-project.name}-dev-cluster"
  cluster_type = "REPLICASET"
  #backup_enabled = true
  mongo_db_major_version = "6.0"
  replication_specs {
    region_configs {
      electable_specs {
        instance_size = "M10"
        node_count    = 3
      }
      #   analytics_specs {
      #     instance_size = "M10"
      #     node_count    = 1
      #   }
      priority      = 7
      provider_name = "AWS"
      region_name   = "EU_CENTRAL_1"
    }
  }
}

resource "mongodbatlas_privatelink_endpoint" "atlaspl" {
  project_id    = mongodbatlas_project.atlas-project.id
  provider_name = "AWS"
  region        = "EU_CENTRAL_1"
}

resource "aws_vpc_endpoint" "ptfe_service" {
  vpc_id             = aws_vpc.main.id
  service_name       = mongodbatlas_privatelink_endpoint.atlaspl.endpoint_service_name
  vpc_endpoint_type  = "Interface"
  subnet_ids         = [aws_subnet.primary.id]
  security_group_ids = [aws_security_group.primary_default.id]
}

resource "mongodbatlas_privatelink_endpoint_service" "atlaseplink" {
  project_id          = mongodbatlas_privatelink_endpoint.atlaspl.project_id
  endpoint_service_id = aws_vpc_endpoint.ptfe_service.id
  private_link_id     = mongodbatlas_privatelink_endpoint.atlaspl.id
  provider_name       = "AWS"
}

locals {
  mongodb_auth_url = replace(
    lookup(mongodbatlas_advanced_cluster.atlas-cluster.connection_strings[0].aws_private_link_srv, aws_vpc_endpoint.ptfe_service.id),
    "mongodb+srv://",
  "mongodb+srv://${mongodbatlas_database_user.db-user.username}:${mongodbatlas_database_user.db-user.password}@")
}

# output "username" {
#   value = mongodbatlas_database_user.db-user.username
# }

# output "user_password" {
#   sensitive = true
#   value     = mongodbatlas_database_user.db-user.password
# }

# output "privatelink_connection_string" {
#   value = lookup(mongodbatlas_advanced_cluster.atlas-cluster.connection_strings[0].aws_private_link_srv, aws_vpc_endpoint.ptfe_service.id)
# }