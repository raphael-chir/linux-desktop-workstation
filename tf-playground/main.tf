# ----------------------------------------
#            Root module
# ----------------------------------------

# Shared tfstate
terraform {
  backend "s3" {
    region = "eu-north-1"
    key    = "desktop-tfstate"
    bucket = "a-tfstate-rch"
  }
}

# Provider config
provider "aws" {
  region = var.region_target
}

# Create a key-pair for logging into ec2 instances
resource "aws_key_pair" "this" {
  key_name   = join("-",[var.resource_tags["project"],var.resource_tags["environment"]])
  public_key = file(join("",[var.ssh_keys_path,".pub"]))
  tags = {
    Name        = join("-",["key-pair", var.resource_tags["project"],var.resource_tags["environment"]])
    Project     = var.resource_tags["project"]
    Owner       = var.resource_tags["owner"]
    Environment = var.resource_tags["environment"]
  }
} 

# Call network module
module "network" {
  source                    = "./modules/network"
  resource_tags             = var.resource_tags
  vpc_cidr_block            = "10.0.0.0/28"
  public_subnet_cidr_block  = "10.0.0.0/28"
}

# Call compute module
module "node01" {
  source                 = "./modules/compute"
  depends_on             = [module.network]
  resource_tags          = var.resource_tags
  base_name              = "ubuntu-18-04"
  instance_ami_id        = "ami-022b0631072a1aefe"
  instance_type          = "t3.2xlarge"
  root_volume_size       = 12
  user_data_script_path  = "scripts/init-talend.sh"
  user_data_args         = {services="data"}
  ssh_public_key_name    = aws_key_pair.this.key_name
  vpc_security_group_ids = module.network.vpc_security_group_ids
  subnet_id              = module.network.subnet_id
}