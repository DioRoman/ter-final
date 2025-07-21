# Web outputs
output "web_vm_private_ips" {
  description = "Private IP addresses of Web VMs"
  value       = module.web-vm.internal_ips
}

output "web_ssh" {
  description = "SSH commands to connect to Web VMs"
  value = [
    for ip in module.web-vm.external_ips : "ssh -l ubuntu ${ip}"
  ]
}