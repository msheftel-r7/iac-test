// ### AWS Variables.

// DivvyCloud software version
variable "divvycloud_version" {
  type = string
}

// AWS Target account id. Where will DivvyCloud be deployed?
variable "account_id" {
  type = string
}

// AWS SSL cert ARN inside of ACM, only used if use_ssl is true
variable "acm_ssl_arn" {
  type = string
  default = null
}

// Allow access to the DivvyCloud UI via these IP address(es)
variable "ingress_whitelist" {
  type = list(string)
}

// Allow access to the DivvyCloud UI via these expanded IP address(es)
variable "ingress_whitelist_expansion" {
  type    = list(string)
  default = []
}

// Target region for DivvyCloud
variable "region" {
  type    = string
  default = "us-east-1"
}

// Target availability zones for DivvyCloud. Exactly 2-3 are required and must be numbered 1, 2, and optionally 3.
variable "az" {
  default = {
    1 = "us-east-1a"
    2 = "us-east-1b"
  }
}

// Name prefix - this will prepend all created resources with a name.
variable "name_prefix" {
  type    = string
  default = "DivvyCloud"
}

// DivvyCloud Fargate cluster suffix. Only used if use_instance_docker is false.
variable "ecs_cluster_name" {
  type    = string
  default = "ECS"
}

// CloudWatch log group suffix for DivvyCloud.
variable "log_group_name" {
  type    = string
  default = "Logs"
}

// Redis instance type
variable "redis_node_type" {
  default = "cache.m5.large"
}

// Mysql instance type
variable "db_instance_class" {
  default = "db.m5.xlarge"
}
// Mysql storage allocation
variable "db_allocated_storage" {
  default = 100
}
variable "db_max_allocated_storage" {
  default = 1024
}
variable "db_snapshot_id" {
  default = null
}
variable "db_custom_version" {
  default = null
}
variable "deletion_protection" {
 default = true
}
// Convert RDS storage from gp2 > io1; set iops value
variable "rds_provisioned_iops" {
  default = null
}

// AMI used if use_instance_docker is true.
variable "ami" {
  type = map(any)
  default = {
    us-east-1 = "ami-00a208c7cdba991ea"
    us-east-2 = "ami-0fc20dd1da406780b"
    us-west-1 = "ami-03ba3948f6c37a4b0"
    us-west-2 = "ami-0d1cd67c26f5fca19"
  }
}

// If set to false an existing ssh key is used
variable "ec2_generate_ssh_key" {
  type    = bool
  default = true
}

// arn of existing ssh key
variable "ec2_custom_ssh_key" {
  type    = string
  default = "your-ssh-key-arn"
}

// IAM Role and Polices name suffix
variable "iam_role_name" {
  type    = string
  default = "Install"
}
variable "override_iam_role_arn" {
  default = null
}
variable "override_iam_role_name" {
  default = null
}

// this is ignored if use_instance_docker is set to true, as this will launch 1 per instance configured below.
variable "interface_server_task_count" {
  type    = number
  default = 2
}

// this is ignored if use_instance_docker is set to true, as this will launch 1 per instance configured below.
variable "scheduler_task_count" {
  type    = number
  default = 2
}

// P2 instances. this is ignored if use_instance_docker is set to true
variable "worker_p2_task_count" {
  type    = number
  default = 16
}

// P0/1 persistent instances. This is replicated out to however many worker instances there are if use_instance_docker is set to true.
variable "worker_p0_p1_task_count" {
  type    = number
  default = 4
}

// Cidr block for the DivvyCloud network. 2-3 private and 2-3 public subnets will be created inside of this.
variable "cidr_block" {
  type    = string
  default = "172.31.0.0/16"
}

// Cpu for interface docker containers
variable "interface_task_cpu" {
  type    = number
  default = 1024
}

// Memory for interface docker containers
variable "interface_task_mem" {
  type    = number
  default = 2048
}

// Cpu for scheduler docker containers
variable "scheduler_task_cpu" {
  type    = number
  default = 1024
}

// Memory for scheduler docker containers
variable "scheduler_task_mem" {
  type    = number
  default = 2048
}

// Cpu for worker docker containers
variable "worker_p0_p1_task_cpu" {
  type    = number
  default = 512
}

// Memory for worker docker containers
variable "worker_p0_p1_task_mem" {
  type    = number
  default = 2048
}

// Cpu for worker docker containers
variable "worker_p2_task_cpu" {
  type    = number
  default = 512
}

// Memory for worker docker containers
variable "worker_p2_task_mem" {
  type    = number
  default = 2048
}

// Access Explorer/IAM specific worker (additional license required)
variable "enable_iam_analyzer" {
  default = false
}
// IAM-specific worker count
variable "worker_p3_task_count" {
  default = 12
}
// Memory for IAM-specific workers
variable "worker_p3_task_mem" {
  default = 2048
}
// CPU for IAM-specific workers
variable "worker_p3_task_cpu" {
  default = 1024
}

// Cloud Collector task
variable "enable_cloud_collector" {
  default = true
}
// Cloud Collector software version
variable "cloud_collector_version" {
  type = string
  default = "public.ecr.aws/divvycloud/divvycloud:cloud-collector-v1.0.15"
}
// Cloud Collector worker count
variable "worker_cc_task_count" {
  default = 12
}
// Memory for Cloud Collector workers
variable "worker_cc_task_mem" {
  default = 2048
}
// CPU for Cloud Collector workers
variable "worker_cc_task_cpu" {
  default = 1024
}

// DEPRECATED; DO NOT ENABLE
// If this is set to true then instances with local docker containers will be created instead of using cloud specific container service
variable "use_instance_docker" {
  type    = bool
  default = false
}

// If this is true then ssl settings must be set in the cloud specific variable. If false then the load balancer will be setup using port 80.
variable "use_ssl" {
  type    = bool
  default = true
}

// ### use_instance_docker specific settings
variable "worker_instance_count" {
  type    = number
  default = 4
}

variable "worker_instance_type" {
  type    = string
  default = "m5.xlarge"
}

variable "interface_scheduler_instance_count" {
  type    = number
  default = 2
}

variable "interface_scheduler_instance_type" {
  type    = string
  default = "c5.large"
}

variable "custom_ecs_env" {
  default = []
}

variable "custom_interfaceserver_ecs_env" {
  default = []
}

variable "custom_worker_p0_p1_ecs_env" {
  default = []
}

variable "custom_worker_p2_ecs_env" {
  default = []
}

variable "custom_worker_p3_ecs_env" {
  default = []
}

variable "custom_worker_cc_ecs_env" {
  default = [
  {
      name = "DIVVY_DISABLE_HEARTBEAT"
      value = "true"
  }
 ]
}

variable "plugin_json" {
  default = null
}

variable "private_alb" {
  default = false
}

// Alarms
variable "alarm_critical_actions" {
  default = []
}
variable "alarm_low_actions" {
  default = []
}

// Network Module Control
variable "module_network_enabled" {
  default = true
}
variable "override_network_vpc" {
  default = null
}
variable "override_network_subnet_private" {
  default = null
}
variable "override_network_subnet_public" {
  default = null
}
// CIDR configuration
variable "subnet_private_offset" {
  default = -1
}
variable "subnet_public_offset" {
  default = -1
}
variable "subnet_private_newbits" {
  default = 4
}
variable "subnet_public_newbits" {
  default = 4
}
variable "subnet_private_netnum_start" {
  default = 0
}
variable "subnet_public_netnum_start" {
  default = 3
}
variable "container_user" {
  type    = string
  default = null
}
variable "interfaceserver_ecs_cmd" {
  default = [
  "divvycloud",
  "webserver",
  "--reverse-proxy",
  "--threads=16"
  ]
}
variable "scheduler_ecs_cmd" {
  default = [
  "divvycloud",
  "scheduler",
  "--db-upgrade",
  "--enqueue-immediately",
  "--distribution-window",
  "1440"
  ]
}
variable "worker_p0_p1_ecs_cmd" {
  default = [
  "divvycloud",
  "worker",
  "--queue",
  "p0",
  "--queue",
  "p1"
  ]
}
variable "worker_p2_ecs_cmd" {
  default = [
  "divvycloud",
  "worker",
  "--queue",
  "p2"
  ]
}
variable "worker_p3_ecs_cmd" {
  default = [
  "divvycloud",
  "worker",
  "--queue",
  "p3"
  ]
}
variable "container_linux_parameters" {
  default = {
    capabilities = {}
    devices      = []
  }
}
variable "custom_tags"{
 type    = map(any)
 default = null
}
// Feature currently disabled
variable "password_expire_days" {
  default = 9999
}
variable "ignore_desired_count_autoscaling" {
  default = true
}

// CVA
variable "enable_cva" {
  default = false
}
variable "cva_db_schema_version" {
  type = string
  default = null
}
variable "cva_img_scanner_version" {
  type = string
  default = null
}
variable "cva_vuln_resolver_version" {
  type = string
  default = null
}
variable "cva_vuln_exporter_version" {
  type = string
  default = null
}
variable "cva_img_processor_version" {
  type = string
  default = null
}
variable "cva_interfaceserver_version" {
  type = string
  default = null
}
variable "cva_secrets_arn" {
  type = string
  default = "arn:aws:secretsmanager:us-east-1:322775321072:secret:DivvyCloud-CVA-Shared-gqfPJe"
}
variable "worker_cva_db_schema_ecs_cmd" {
  default = [
  "./cva_db_schema"
  ]
}
variable "worker_cva_img_scanner_ecs_cmd" {
  default = [
  "/home/appuser/executor"
  ]
}
variable "worker_cva_vuln_resolver_ecs_cmd" {
  default = []
}
variable "worker_cva_vuln_exporter_ecs_cmd" {
  default = []
}
variable "worker_cva_img_processor_ecs_cmd" {
  default = []
}
variable "worker_cva_interfaceserver_ecs_cmd" {
  default = []
}
variable "custom_worker_cva_ecs_env" {
  default = []
}
variable "custom_worker_cva_db_schema_create_ecs_env" {
  default = [
  {
    name  = "EXEC_MODE"
    value = "CREATE"
  }
  ]
}
variable "custom_worker_cva_db_schema_validate_ecs_env" {
  default = [
  {
    name  = "EXEC_MODE"
    value = "VALIDATE"
  },
  {
    name  = "RETRY_COUNT"
    value = "5"
  },
  {
    name  = "RETRY_DELAY"
    value = "10"
  },
  ]
}
variable "custom_worker_cva_img_scanner_ecs_env" {
  default = [
  {
    name  = "IMAGES_DIR"
    value = "/tmp/images"
  },
  {
    name  = "REPORT_DIR"
    value = "/tmp/report"
  }
  ]
}
variable "custom_worker_cva_vuln_resolver_ecs_env" {
  default = [
  {
    name  = "IVM_API_CALL_METHOD"
    value = "proxy"
  },
  {
    name  = "THREAD_POOL_SIZE"
    value = "4"
  }
  ]
}
variable "custom_worker_cva_vuln_exporter_ecs_env" {
  default = [
  {
    name  = "EXPORT_POLL_RATE"
    value = "100000"
  },
  {
    name  = "REDIS_SSL_ENABLED"
    value = "true"
  },
  {
    name  = "REDIS_MESSAGE_QUEUE"
    value = "divvy:container_assessment:assessed_queue"
  }
  ]
}
variable "custom_worker_cva_img_processor_ecs_env" {
  default = [
  {
    name  = "REDIS_SSL_ENABLED"
    value = "true"
  },
  {
    name  = "REDIS_MESSAGE_QUEUE"
    value = "divvy:harvested:containers"
  }
  ]
}
variable "custom_worker_cva_interfaceserver_ecs_env" {
  default = [
  {
    name  = "SPRING_PROFILES_ACTIVE"
    value = "mysql"
  }
  ]
}
variable "worker_cva_task_count" {
  default = 1
}
variable "worker_cva_task_mem" {
  default = 4096
}
variable "worker_cva_task_cpu" {
  default = 2048
}
// end CVA

// RunGuard
variable "enable_runguard" {
  default = false
}
variable "license_fingerprint" {
  default = null
}
variable "platform_id" {
  default = null
}
variable "runguard_trust_role" {
  type    = string
  default = "arn:aws:iam::697158651567:role/ics-cwp-nvirginia-flow-logs-generic-role"
}
variable "runguard_config_s3_bucket_name" {
  type    = string
  default = "ics-runguard-production-tenant-config"
}

variable "runguard_config_s3_bucket_location" {
  type    = string
  default = "us-east-1"
}
// end RunGuard

// Trailblazer
variable "enable_trailblazer" {
  default = false
}
  
variable "trailblazer_trust_role" {
  type    = string
  default = "arn:aws:iam::697158651567:role/ics-cwp-nvirginia-flow-logs-generic-role"
}
// end Trailblazer

variable "enable_debug_container" {
  default = false
}

variable "debug_container_image" {
  default = "786191184619.dkr.ecr.us-east-1.amazonaws.com/divvycloud:debug"
}

variable "debug_command" {
  default = []
}

variable "flowlog_format" {
  default = "$${version} $${account-id} $${interface-id} $${srcaddr} $${dstaddr} $${srcport} $${dstport} $${protocol} $${packets} $${bytes} $${start} $${end} $${action} $${log-status}"
}

variable "disable_flow_log_bucket_owner_enforced" {
  default = false
}
variable "enable_ecs_capacity_resource" {
 default = true
}

variable "log_to_s3" {
 default = true
}

variable "tc_evaluation_periods" {
  //(12 * 900)/60 = 180 (3h)
  default = 12
  description = "Number of 900s periods w/o success; tripping alarm"
}

variable "use_interfaceserver_autoscaling" {
  default = true
}
variable "min_interfaceserver_capacity" {
  description = "Minimum number of interfaceserver tasks the autoscaler should permit"
  default = 2
}
variable "max_interfaceserver_capacity" {
  description = "Maximum number of interfaceserver tasks the autoscaler should permit"
  default = 16
}
