# llama.up

Provision a [llama.cpp](https://github.com/ggerganov/llama.cpp) on AWS with the help of Terraform

:exclamation: :exclamation: WARNING Public cloud instances can get expensive. Make sure to keep track of provisioned and running instances :exclamation: :exclamation:


This terraform configuration will provision, deploy and start a server llama.cpp on an AWS instance.

Features:
* Compilation for CUDA, OpenBlas and Intel oneMKL
* secure endpoints with an API key (this was created before native support for API keys)
* https support (only self-signed certificates for now)
* user defined models

llama.up uses [Apache APISIX](https://apisix.apache.org) as API gateway.

## Pre-requisites

* An AWS account and credentials (key ID and secret access key)
* Terraform installed or docker (for the terraform docker image)
* `curl`
* Optional: An [AWS keypair](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html) (optional but recommended)
* Make up an API key for the llama.cpp API calls and an admin key for the API server

## Provisioning

I recommend just using the terraform docker image. If you already have terraform installed, make sure `curl` is installed as well as it's used to check when provisioning is complete.

By default a **t2.medium** is provisioned on **us-east-2** with an inexpensive (but slow) 100G Hard Disk Drive (yes, not SSD).

clone this repository and start a docker container
```
git clone https://github.com/bignacio/llama.up/


docker run -i -t --rm -v `pwd`:/tf --entrypoint /bin/sh hashicorp/terraform:latest

cd /tf
```

setup your AWS credentials in the container
```
export AWS_ACCESS_KEY_ID=<ACCESS KEY ID>
export AWS_SECRET_ACCESS_KEY=<SECRET ACCESS KEY>
```

Apply the terraform configuration.

By default, it will provision an AWS instance from a standard AMI, which can take a very long time (see below how to use an existing, pre-provisioned).


**If you're not using docker, you can start from this point**

```
terraform init
terraform apply -var="aws-region=<MY AWS REGION>" -var="main-apisix_llamacpp_key=<MY_API_KEY>" -var="main-apisix_admin_key=<APISIX_ADMIN_KEY>" -var="aws-key_name=<EXISTING AWS KEYPAIR>"
```

where `MY_API_KEY` is the key to be used for any API call to the service.

This will take about 1h to complete using the default configuration and once complete, you can check the service status hitting the `health` endpoint.

```
curl -ks --resolve llamaup.org:443:<INSTANCE PUBLIC IP> https://llamaup.org/health -H 'Authorization: MY_API_KEY'

{"status": "ok"}
```

Note that the default header for the API key is `Authorization`

## More provisioning options

### Setting an instance type and hardware platform

The variable `aws-instance_type` allows specifying the AWS instance to be created and provisioned.

The variable `main-hw_platform` allows specifying the hardware platform for which llama.cpp will be built. Possible values are `cuda`, `intel` and `openblas`.
AMD ROCM is not yet supported, sorry.

For example, to provision an instance with llama.cpp optimized for CUDA, execute

```
terraform apply -var="aws-region=<MY AWS REGION>" -var="main-apisix_llamacpp_key=<MY_API_KEY>" -var="main-apisix_admin_key=<APISIX_ADMIN_KEY>" -var="aws-key_name=<EXISTING AWS KEYPAIR>" -var="aws-instance_type=g4dn.xlarge" -var="main-hw_platform=cuda"
```

### Setting other llama.cpp options

Other variables can be passed to terraform to control the model provisioned, llama.cpp git repository tag (version) and extra parameters to be passed to the server on startup.

These variables are:

* `main-model_url`: full url to the model file. It must be available for download via `wget` (accessible to the instance being provisioned)
* `main-llamacpp_server_extra_args`: arguments to be passed to the server process. All options in `server --help` are accepted
* `main-llamacpp_git_tag`: llama.cpp repository tag


## Hacking llama.up

This is a regular terraform module and the main file is in [modules/llamacpp_aws/main.tf](modules/llamacpp_aws/main.tf).

The bash shell script file [setup_env.sh](setup_env.sh) does the main provisioning (dependencies, services installation and configuration).
It requires 3 parameters: <llama.cpp tag> <hardware platform> <full model url>

The bash shell script file [build_llamacpp.sh](build_llamacpp.sh) downloads and builds llama.cpp.
It requires 3 parameters: <llama.cpp tag> <hardware platform> <full model url>


Also, instead of passing terraform variables via command line, you can edit or add them to [terraform.tfvars](terraform.tfvars)

## Faster provisioning and Keeping llama.cpp and models up to date

After provisioning the first instance, you can [create an AMI](https://docs.aws.amazon.com/toolkit-for-visual-studio/latest/user-guide/tkv-create-ami-from-instance.html) from that instance and use it to provision new instances by setting the terraform variable `aws-ami_id`.

This will cut down provisioning time substantially and it can also be used to just update the version of llama.cpp or deploy a new model.

If you just want to update llama.cpp or the model without creating a new instance (which makes sense) ssh into the running instance and run

```
sudo /llama.up/build_llamacpp.sh <llama.cpp tag> <hardware platform> <full model url>
```

This will build and restart the service with new binary and model.