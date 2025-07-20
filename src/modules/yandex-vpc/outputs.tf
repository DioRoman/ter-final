output "network_id" {
  description = "ID созданной VPC сети"
  value       = yandex_vpc_network.network.id
}

output "network_name" {
  description = "Имя созданной VPC сети"
  value       = yandex_vpc_network.network.name
}

output "subnet_ids" {
  description = "Map ID созданных подсетей по зонам"
  value = [for subnet in yandex_vpc_subnet.subnets : subnet.id]
}

# output "security_group_id" {
#   description = "ID созданной группы безопасности"
#   value       = yandex_vpc_security_group.main.id
# }

output "security_group_ids" {
  value       = { for k, v in yandex_vpc_security_group.sg : k => v.id }
  description = "Map с ID созданных групп безопасности (ключ - имя группы)"
}