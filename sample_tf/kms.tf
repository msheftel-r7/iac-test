module "kms" {
  source      = "https://s3.amazonaws.com/get.divvycloud.com/prodserv/divvycloud-prodserv-tf/modules/aws/kms.zip"
  name_prefix = var.name_prefix
  account_id  = var.account_id
}
