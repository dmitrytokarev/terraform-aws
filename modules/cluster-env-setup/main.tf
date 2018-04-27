module "cluster_configured" {
  source = "../services/webserver-cluster"

  cluster_name           = "webservers-${var.environment}"
  db_remote_state_bucket = "${var.db_remote_state_bucket}"
  db_remote_state_key    = "${var.environment}/data-stores/mysql/terraform.tfstate"
  db_remote_state_region = "us-west-2"
}
