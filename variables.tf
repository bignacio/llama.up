variable "aws-instance_type" {
  description = "The type of EC2 instance to launch"
  type        = string
  default     = "t2.micro"
}

variable "aws-ami_id" {
  description = "The ID of the Amazon Machine Image (AMI) to use for the instance"
  type        = string
  default     = "ami-05fb0b8c1424f266b" # us-east-2 Canonical, Ubuntu, 22.04 LTS, amd64 jammy image build on 2023-12-07
}

variable "aws-key_name" {
  description = "The name for AWS key pair"
  type = string
  default = null
}


variable "aws-region" {
  description = "AWS Region"
  type = string
  default = "us-east-1"
}

variable "main-apisix_admin_key" {
  description = "The key for APISIX admin"
  type = string
}

variable "main-apisix_llamacpp_key" {
  description = "The key for APISIX admin"
  type = string
}

variable "main-llamacpp_server_extra_args" {
  description = "llama.cpp server extra command line arguments"
  type = string
  default = ""
}

variable "main-llamacpp_git_tag" {
  description = "llama.cpp git tag"
  type = string
  default = "b1892"
}

variable "main-hw_platform" {
  description = "hardware platform. It can be cuda, intel or openblas"
  type = string
  default = "openblas"
}


variable "main-model_url" {
  description = "url to the llama model. Default to a low quality mistral model"
  type = string
  default = "https://huggingface.co/TheBloke/Mistral-7B-Instruct-v0.2-GGUF/resolve/main/mistral-7b-instruct-v0.2.Q2_K.gguf"
}