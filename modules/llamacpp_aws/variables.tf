variable "tags"{
  description = "Tags for aws resources"
  type = map(string)
  default = {
    llamaup_version = "0.1"
    provisioner = "llamaup"
  }
}

variable "instance_type" {
  description = "The type of EC2 instance to launch"
  type        = string
  default     = null
}

variable "ami_id" {
  description = "The ID of the Amazon Machine Image (AMI) to use for the instance"
  type        = string
}


variable "key_name" {
  description = "The name for AWS key pair"
  type = string
}


variable "region" {
  description = "The AWS region to deploy the instance"
  type = string
  default = null
}

variable "apisix_admin_key" {
  description = "The key for APISIX admin"
  type = string
}

variable "apisix_llamacpp_key" {
  description = "llama.cpp API key"
  type = string
}

variable "llamacpp_server_extra_args" {
  description = "llama.cpp server extra command line arguments"
  type = string
  default = ""
}

variable "llamacpp_git_tag" {
  description = "llama.cpp git tag"
  type = string
}

variable "hw_platform" {
  description = "hardware platform. It can be cuda, intel or openblas"
  type = string
}

variable "model_url" {
  description = "url to the llama model. Default to a low quality mistral model"
  type = string
}