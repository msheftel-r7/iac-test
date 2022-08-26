provider "aws" {
  // Uncomment/update value if non-default profile is being used
  //profile             = "default"
  allowed_account_ids = [var.account_id]

  // vars.tf
  region = var.region

  default_tags {
   tags = var.custom_tags
  }
}
