module "llamacpp_aws" {
  region = var.aws-region
  ami_id = var.aws-ami_id
  source = "./modules/llamacpp_aws"
  instance_type = var.aws-instance_type
  key_name = var.aws-key_name
  apisix_admin_key = var.main-apisix_admin_key
  apisix_llamacpp_key = var.main-apisix_llamacpp_key
  llamacpp_server_extra_args = var.main-llamacpp_server_extra_args
  llamacpp_git_tag = var.main-llamacpp_git_tag
  hw_platform = var.main-hw_platform
  model_url = var.main-model_url
}