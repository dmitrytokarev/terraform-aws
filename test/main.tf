locals {
  environment = "test"
}

//module "cluster_env" {
//  source = "../modules/cluster-env-setup"
//
//  environment = "${local.environment}"
//}

module "webserver_cluster" {
  source = "../modules/services/webserver-cluster"

  cluster_name           = "webservers-${local.environment}"
  db_remote_state_bucket = "${var.db_remote_state_bucket}"
  db_remote_state_key    = "${local.environment}/data-stores/mysql/terraform.tfstate"
  db_remote_state_region = "us-west-2"
}
