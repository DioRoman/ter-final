output "instance_ids" {
  description = "Список ID созданных виртуальных машин"
  value       = yandex_compute_instance.vm[*].id
}

output "instance_names" {
  description = "Список имен созданных виртуальных машин"
  value       = yandex_compute_instance.vm[*].name
}

output "external_ips" {
  description = "Список внешних IP-адресов"
  value       = yandex_compute_instance.vm[*].network_interface.0.nat_ip_address
}

output "internal_ips" {
  description = "Список внутренних IP-адресов"
  value       = yandex_compute_instance.vm[*].network_interface.0.ip_address
}

output "network_interfaces" {
  description = "Список сетевых интерфейсов ВМ"
  value       = yandex_compute_instance.vm[*].network_interface
}

output "boot_disks" {
  description = "Список загрузочных дисков ВМ"
  value       = yandex_compute_instance.vm[*].boot_disk
}
