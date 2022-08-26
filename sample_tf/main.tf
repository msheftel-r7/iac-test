// AWS Deployment of DivvyCloud

module "iam" {
  source                 = "https://s3.amazonaws.com/get.divvycloud.com/prodserv/divvycloud-prodserv-tf/modules/aws/iam.zip"
  name_prefix            = var.name_prefix
  iam_role_name          = join("-", [var.name_prefix, var.iam_role_name])
  //cloud_collector_s3_arn = module.divvy_server.cloud_collector_s3_arn

  // vars.tf
  use_instance_docker = var.use_instance_docker

  create_install_role  = var.override_iam_role_arn != null ? false : true

  // CVA
  enable_cva      = var.enable_cva
  cva_secrets_arn = var.cva_secrets_arn

  // RunGuard
  enable_runguard                = var.enable_runguard
  license_fingerprint            = var.license_fingerprint
  runguard_trust_role            = var.runguard_trust_role
  runguard_config_s3_bucket_name = var.runguard_config_s3_bucket_name

  // Trailblazer
  enable_trailblazer             = var.enable_trailblazer
  platform_id                    = var.platform_id
  trailblazer_trust_role         = var.trailblazer_trust_role
}

module "network" {
  source      = "https://s3.amazonaws.com/get.divvycloud.com/prodserv/divvycloud-prodserv-tf/modules/aws/network.zip"
  count  = var.module_network_enabled ? 1 : 0

  name_prefix = var.name_prefix
  account_id  = var.account_id

  region     = var.region
  az         = var.az
  cidr_block = var.cidr_block

  subnet_private_offset                  = var.subnet_private_offset
  subnet_public_offset                   = var.subnet_public_offset
  subnet_private_newbits                 = var.subnet_private_newbits
  subnet_public_newbits                  = var.subnet_public_newbits
  subnet_private_netnum_start            = var.subnet_private_netnum_start
  subnet_public_netnum_start             = var.subnet_public_netnum_start
  flowlog_format                         = var.flowlog_format
  disable_flow_log_bucket_owner_enforced = var.disable_flow_log_bucket_owner_enforced

  depends_on = [module.kms]
}

module "firewall" {
  source      = "https://s3.amazonaws.com/get.divvycloud.com/prodserv/divvycloud-prodserv-tf/modules/aws/firewall.zip"
  name_prefix = var.name_prefix

  vpc                         = var.override_network_vpc != null ? var.override_network_vpc : module.network[0].vpc
  ingress_whitelist           = var.ingress_whitelist
  ingress_whitelist_expansion = var.ingress_whitelist_expansion
  use_ssl                     = var.use_ssl

  depends_on = [module.network]
}

module "password_rotation" {
  source               = "https://s3.amazonaws.com/get.divvycloud.com/prodserv/divvycloud-prodserv-tf/modules/aws/password_rotation.zip"
  password_expire_days = var.password_expire_days
}

module "redis" {
  source      = "https://s3.amazonaws.com/get.divvycloud.com/prodserv/divvycloud-prodserv-tf/modules/aws/redis.zip"
  name_prefix = var.name_prefix

  kms_key_arn = module.kms.kms_key_arn

  node_type = var.redis_node_type

  // Feature currently disabled
  // rotation_trigger = module.password_rotation.rotation_trigger

  // Network
  sg             = module.firewall.sg
  subnet_private = var.override_network_subnet_private != null ? var.override_network_subnet_private : module.network[0].subnet_private

  depends_on = [module.iam]
}

module "mysql" {
  source      = "https://s3.amazonaws.com/get.divvycloud.com/prodserv/divvycloud-prodserv-tf/modules/aws/mysql.zip"
  name_prefix = var.name_prefix

  // IAM
  role_rds_monitor_arn = module.iam.role_rds_monitor_arn

  kms_key_arn = module.kms.kms_key_arn

  custom_instance_class = var.db_instance_class

  // Feature currently disabled
  // rotation_trigger = module.password_rotation.rotation_trigger_db

  // Network
  sg             = module.firewall.sg
  subnet_private = var.override_network_subnet_private != null ? var.override_network_subnet_private : module.network[0].subnet_private

  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage
  snapshot_identifier   = var.db_snapshot_id
  custom_version        = var.db_custom_version
  rds_provisioned_iops  = var.rds_provisioned_iops
  database_username     = "divvy"
  deletion_protection   = var.deletion_protection

  depends_on = [module.iam]
}

module "secret" {
  source      = "https://s3.amazonaws.com/get.divvycloud.com/prodserv/divvycloud-prodserv-tf/modules/aws/secret.zip"
  name_prefix = var.name_prefix

  // IAM
  role_name      = var.override_iam_role_name != null ? var.override_iam_role_name : module.iam.role_name
  role_exec_name = module.iam.role_exec_name

  // Feature currently disabled
  // rotation_trigger = module.password_rotation.rotation_trigger

  // Credentials
  db_name        = module.mysql.db_name
  secret_db_name = module.mysql.secret_db_name
  host           = module.mysql.host
  username       = module.mysql.username
  password       = module.mysql.password
  port           = module.mysql.port
  redis_host     = module.redis.redis_host
  redis_password = module.redis.redis_password
  redis_port     = module.redis.redis_port

  // CVA
  enable_cva     = var.enable_cva

  depends_on = [module.iam, module.redis, module.mysql]
}

module "alb" {
  source      = "https://s3.amazonaws.com/get.divvycloud.com/prodserv/divvycloud-prodserv-tf/modules/aws/alb.zip"
  name_prefix = var.name_prefix
  account_id  = var.account_id
  region      = var.region

  use_ssl     = var.use_ssl
  acm_ssl_arn = var.acm_ssl_arn
  private_alb = var.private_alb
  log_to_s3   = var.log_to_s3

  use_instance_docker = var.use_instance_docker
  sg                  = module.firewall.sg
  subnet              = var.override_network_subnet_public != null ? var.override_network_subnet_public : module.network[0].subnet_public
  vpc                 = var.override_network_vpc != null ? var.override_network_vpc : module.network[0].vpc

  depends_on = [module.iam]
}

module "divvy_server" {
  source      = "https://s3.amazonaws.com/get.divvycloud.com/prodserv/divvycloud-prodserv-tf/modules/aws/divvy_server.zip"
  name_prefix = var.name_prefix

  ecs_cluster_name     = join("-", [var.name_prefix, var.ecs_cluster_name])
  log_group_name       = join("-", [var.name_prefix, var.log_group_name])
  ami                  = var.ami
  ec2_generate_ssh_key = var.ec2_generate_ssh_key
  ec2_custom_ssh_key   = var.ec2_custom_ssh_key

  // IAM
  role_exec_arn = module.iam.role_exec_arn
  role_arn      = var.override_iam_role_arn != null ? var.override_iam_role_arn : module.iam.role_arn
  role_name     = var.override_iam_role_name != null ? var.override_iam_role_name : module.iam.role_name

  // Network
  sg             = module.firewall.sg
  subnet_private = var.override_network_subnet_private != null ? var.override_network_subnet_private : module.network[0].subnet_private
  vpc            = var.override_network_vpc != null ? var.override_network_vpc : module.network[0].vpc

  // Mysql/Redis secret
  db_secret     = module.secret.db_secret
  db_secret_arn = module.secret.db_secret_arn

  // vars.tf
  region              = var.region
  use_instance_docker = var.use_instance_docker

  plugin_json                    = var.plugin_json
  custom_ecs_env                 = var.custom_ecs_env
  custom_interfaceserver_ecs_env = var.custom_interfaceserver_ecs_env
  custom_worker_p0_p1_ecs_env    = var.custom_worker_p0_p1_ecs_env
  custom_worker_p2_ecs_env       = var.custom_worker_p2_ecs_env
  custom_worker_cc_ecs_env       = var.custom_worker_cc_ecs_env
  interfaceserver_ecs_cmd        = var.interfaceserver_ecs_cmd
  scheduler_ecs_cmd              = var.scheduler_ecs_cmd
  worker_p0_p1_ecs_cmd           = var.worker_p0_p1_ecs_cmd
  worker_p2_ecs_cmd              = var.worker_p2_ecs_cmd

  use_worker_p2_autoscaling          = true
  ignore_desired_count_autoscaling   = var.ignore_desired_count_autoscaling

  container_user                     = var.container_user
  container_linux_parameters         = var.container_linux_parameters
  divvycloud_version                 = var.divvycloud_version
  cloud_collector_version            = var.cloud_collector_version
  interface_server_task_count        = var.interface_server_task_count
  scheduler_task_count               = var.scheduler_task_count
  worker_p0_p1_task_count            = var.worker_p0_p1_task_count
  worker_p2_task_count               = var.worker_p2_task_count
  worker_p0_p1_task_cpu              = var.worker_p0_p1_task_cpu
  worker_p0_p1_task_mem              = var.worker_p0_p1_task_mem
  worker_p2_task_cpu                 = var.worker_p2_task_cpu
  worker_p2_task_mem                 = var.worker_p2_task_mem
  worker_instance_count              = var.worker_instance_count
  worker_instance_type               = var.worker_instance_type
  interface_scheduler_instance_count = var.interface_scheduler_instance_count
  interface_scheduler_instance_type  = var.interface_scheduler_instance_type
  interface_task_cpu                 = var.interface_task_cpu
  interface_task_mem                 = var.interface_task_mem
  scheduler_task_cpu                 = var.scheduler_task_cpu
  scheduler_task_mem                 = var.scheduler_task_mem
  lb_target_group_arn                = module.alb.lb_target_group_arn

  // IAM Access Explorer
  enable_iam_analyzer      = var.enable_iam_analyzer
  worker_p3_task_count     = var.worker_p3_task_count
  worker_p3_ecs_cmd        = var.worker_p3_ecs_cmd
  custom_worker_p3_ecs_env = var.custom_worker_p3_ecs_env

  // Cloud Collector/Azure EDH
  enable_cloud_collector   = var.enable_cloud_collector
  worker_cc_task_count     = var.worker_cc_task_count
  worker_cc_task_cpu       = var.worker_cc_task_cpu
  worker_cc_task_mem       = var.worker_cc_task_mem

  // CVA
  enable_cva                                   = var.enable_cva
  cva_secrets_arn                              = var.cva_secrets_arn

  cva_db_schema_version                        = var.cva_db_schema_version
  cva_img_scanner_version                      = var.cva_img_scanner_version
  cva_vuln_resolver_version                    = var.cva_vuln_resolver_version
  cva_vuln_exporter_version                    = var.cva_vuln_exporter_version
  cva_img_processor_version                    = var.cva_img_processor_version
  cva_interfaceserver_version                  = var.cva_interfaceserver_version

  worker_cva_db_schema_ecs_cmd                 = var.worker_cva_db_schema_ecs_cmd
  worker_cva_img_scanner_ecs_cmd               = var.worker_cva_img_scanner_ecs_cmd
  worker_cva_vuln_resolver_ecs_cmd             = var.worker_cva_vuln_resolver_ecs_cmd
  worker_cva_vuln_exporter_ecs_cmd             = var.worker_cva_vuln_exporter_ecs_cmd
  worker_cva_img_processor_ecs_cmd             = var.worker_cva_img_processor_ecs_cmd
  worker_cva_interfaceserver_ecs_cmd           = var.worker_cva_interfaceserver_ecs_cmd

  custom_worker_cva_ecs_env                    = var.custom_worker_cva_ecs_env
  custom_worker_cva_db_schema_create_ecs_env   = var.custom_worker_cva_db_schema_create_ecs_env
  custom_worker_cva_db_schema_validate_ecs_env = var.custom_worker_cva_db_schema_validate_ecs_env
  custom_worker_cva_img_scanner_ecs_env        = var.custom_worker_cva_img_scanner_ecs_env
  custom_worker_cva_vuln_resolver_ecs_env      = var.custom_worker_cva_vuln_resolver_ecs_env
  custom_worker_cva_vuln_exporter_ecs_env      = var.custom_worker_cva_vuln_exporter_ecs_env
  custom_worker_cva_img_processor_ecs_env      = var.custom_worker_cva_img_processor_ecs_env
  custom_worker_cva_interfaceserver_ecs_env    = var.custom_worker_cva_interfaceserver_ecs_env

  worker_cva_task_count                        = var.worker_cva_task_count
  worker_cva_task_mem                          = var.worker_cva_task_mem
  worker_cva_task_cpu                          = var.worker_cva_task_cpu

  // RunGuard
  enable_runguard                    = var.enable_runguard
  runguard_config_s3_bucket_name     = var.runguard_config_s3_bucket_name
  runguard_config_s3_bucket_location = var.runguard_config_s3_bucket_location
  account_id                         = var.account_id

  enable_ecs_capacity_resource = var.enable_ecs_capacity_resource

  depends_on = [module.secret, module.alb]
}

module "cloudwatch" {
  source           = "https://s3.amazonaws.com/get.divvycloud.com/prodserv/divvycloud-prodserv-tf/modules/aws/cloudwatch.zip"
  name_prefix      = var.name_prefix
  ecs_cluster_name = module.divvy_server.ecs_cluster_name
  ecs_cluster_arn  = module.divvy_server.ecs_cluster_arn

  // Server
  log_group_name        = module.divvy_server.log_group_name
  ec2_asg_worker_name   = module.divvy_server.ec2_asg_worker_name
  ec2_asg_ui_sched_name = module.divvy_server.ec2_asg_ui_sched_name

  // vars.tf
  use_instance_docker      = var.use_instance_docker
  db_identifier            = module.mysql.db_identifier
  db_max_allocated_storage = var.db_max_allocated_storage
  region                   = var.region
  db_instance_class        = var.db_instance_class

  alarm_critical_actions = var.alarm_critical_actions
  alarm_low_actions      = var.alarm_low_actions

  tc_evaluation_periods = var.tc_evaluation_periods

  depends_on = [module.divvy_server]
}

module "autoscale" {
  count                           = var.use_instance_docker ? 0 : 1
  source                          = "https://s3.amazonaws.com/get.divvycloud.com/prodserv/divvycloud-prodserv-tf/modules/aws/autoscale.zip"
  name_prefix                     = var.name_prefix
  ecs_cluster_name                = module.divvy_server.ecs_cluster_name
  ecs_worker_name                 = module.divvy_server.ecs_worker_p2_name
  ecs_interfaceserver_name        = module.divvy_server.ecs_interfaceserver_name
  use_interfaceserver_autoscaling = var.use_interfaceserver_autoscaling
  min_interfaceserver_capacity    = var.min_interfaceserver_capacity
  max_interfaceserver_capacity    = var.max_interfaceserver_capacity
  min_capacity                    = 16
  max_capacity                    = 150
  depends_on                      = [module.divvy_server, module.cloudwatch]
}

module "debug" {
  source            = "https://s3.amazonaws.com/get.divvycloud.com/prodserv/divvycloud-prodserv-tf/modules/aws/debug.zip"
  region            = var.region
  db_secret         = module.secret.db_secret
  ecs_cluster_arn   = module.divvy_server.ecs_cluster_arn
  log_group_name    = join("-", [var.name_prefix, var.log_group_name, "debug"])
  name_prefix       = var.name_prefix
  role_exec_arn     = module.iam.role_exec_arn
  role_arn          = var.override_iam_role_arn != null ? var.override_iam_role_arn : module.iam.role_arn
  command           = var.debug_command
  sg                = module.firewall.sg
  subnet_private    = var.override_network_subnet_private != null ? var.override_network_subnet_private : module.network[0].subnet_private
  debug_data_retention_days = null
  kms_key_arn       = module.kms.kms_key_arn
  enable            = var.enable_debug_container
  debug_container_image = var.debug_container_image
}
