# ---------------------------------------------
#    Root Module Output return variables
# ---------------------------------------------

output "instance01-ssh" {
  value = join("",["ssh -i ", var.ssh_keys_path, " ubuntu@", module.node01.public_ip])
}

output "instance01_public_dns" {
  value = module.node01.public_dns
}