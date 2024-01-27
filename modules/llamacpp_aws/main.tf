provider "aws" {
  region = var.region
}

resource "aws_instance" "llamaup" {
  ami = var.ami_id
  instance_type = var.instance_type

  key_name = var.key_name

  user_data = <<-EOF
            #!/bin/bash
            apt install git -y
            cd /
            rm -rf llama.up
            git clone https://github.com/bignacio/llama.up
            sed -i 's/__APISIX_ADMIN_KEY_VAR__/${var.apisix_admin_key}/g' /llama.up/apisix-conf.yaml
            sed -i 's/__APISIX_ADMIN_KEY_VAR__/${var.apisix_admin_key}/g' /llama.up/configure-apisix.sh
            sed -i 's/__APISIX_LLAMACPP_APIKEY_VAR__/${var.apisix_llamacpp_key}/g' /llama.up/apisix-consumer.json
            sed -i 's/__LLAMACPP_SERVER_EXTRA_ARGS__/${var.llamacpp_server_extra_args}/g' /llama.up/llamacpp.service

            cd /llama.up
            ./setup_env.sh ${var.llamacpp_git_tag} ${var.hw_platform} ${var.model_url}  > provision.log 2>&1
          EOF


  root_block_device {
    volume_size = 100
    volume_type = "standard"  # magnetic (HDD) storage
  }

  tags = var.tags
  vpc_security_group_ids = [aws_security_group.llamaup-secgroup.id]
}


resource "aws_security_group" "llamaup-secgroup" {
  name        = "llamaup-security-group"
  description = "Created by llamaup"

  #vpc_id = aws_instance.llamaup.vpc_id

  # HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ssh
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "null_resource" "wait_for_instance" {
  triggers = {
    instance_id = aws_instance.llamaup.id
  }

  provisioner "local-exec" {
    command = "until curl -ks --resolve llamaup.org:443:${aws_instance.llamaup.public_ip} https://llamaup.org/health -H 'Authorization: ${var.apisix_llamacpp_key}' | grep -q '\"status\":'; do sleep 30; done"
  }
}