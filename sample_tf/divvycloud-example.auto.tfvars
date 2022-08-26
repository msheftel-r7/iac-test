// DivvyCloud container/version to deploy
divvycloud_version = "public.ecr.aws/divvycloud/divvycloud:v22.3.9"

// CloudCollector container/version to deploy
//cloud_collector_version = "public.ecr.aws/divvycloud/divvycloud:cloud-collector-v1.0.15"

// Target AWS account ID for deployment
account_id = "XXXXXXXXXXXX"

// Target region
region = "us-east-1"

// Target AZs
az = {
  1 = "us-east-1a"
  2 = "us-east-1b"
}

// Existing ACM SSL certificate to associate with ALB/UI
acm_ssl_arn = "arn:aws:acm:REGION:ACCOUNT-ID:certificate/XXXXXXXXXXXXXX"

// Internet-facing or internal ALB?
private_alb = false

// CIDR range/list allowed access to ALB/UI
ingress_whitelist = ["YOUR-CIDR-RANGE-HERE/32"]

// SNS Topics to send critical monitoring alarms too. This can be left blank if not needed.
alarm_critical_actions = [] // ["arn:aws:sns:REGION:ACCOUNT-ID:XXXXXXXXXXXXXXXXXX"]

// SNS Topics to send low priority monitoring alarms too. This can be left blank if not needed.
alarm_low_actions = [] // ["arn:aws:sns:REGION:ACCOUNT-ID:XXXXXXXXXXXXXXXXXX"]

// Add custom tags to every supported resource
//custom_tags = {
//    Product     = "DivvyCloud"
//    Environment = "Production"
//}

// If you do *not* want to create a new VPC/subnets, uncomment and populate the following
// module_network_enabled          = false
// override_network_vpc            = "vpc-XXXXXXXXXXXX"
// override_network_subnet_private = ["subnet-XXXXXXXXXXXX", "subnet-XXXXXXXXXXXX"]
// Internet-facing ALB is the only infrastructure attached to public subnets
// If using an internal ALB, populate with same private subnet IDs used above
// override_network_subnet_public  = ["subnet-XXXXXXXXXXXX", "subnet-XXXXXXXXXXXX"]

// Enable RDS storage auto-scaling; set max capacity in GB (recommended)
db_max_allocated_storage = 1024

// If you want to restore from a database snapshot on initial deployment set the snapshot identifier below
// db_snapshot_id = "divvycloud-migration-snapshot"

// If you want to override the iam role used set the arn and role name below
// override_iam_role_arn  = ""
// override_iam_role_name = ""

// Enable IAM/Access Explorer? (requires additional license)
enable_iam_analyzer = false
