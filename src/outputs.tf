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

output "curl_webapp" {
  description = "Curl to Web VMs"
  value = [
    for ip in module.web-vm.external_ips : "curl -L http://${ip}:8090"
  ]
}

output "mysql_host" {
  value = module.mysql.fqdn
}

output "mysql_database" {
  value = yandex_mdb_mysql_database.my_db.name
}

output "mysql_user" {
  value = yandex_mdb_mysql_user.admin_user.name
}

output "mysql_password" {
  value     = data.yandex_lockbox_secret_version.mysql_password_data.entries[0].text_value
  sensitive = true
}
