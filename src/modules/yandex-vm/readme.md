# Yandex Cloud Compute Instance Module

Модуль для создания виртуальных машин в Yandex Cloud.

## Использование

```hcl
module "compute_instance" {
  source = "./modules/yandex-compute-instance"

  vm_name          = "web-server"
  vm_count         = 2
  folder_id        = "b1gxxxxxxxxxxxxxx"
  subnet_ids       = ["e9bxxxxxxxxxxxxxx", "e9bxxxxxxxxxxxxxy"]
  security_group_ids = ["enpxxxxxxxxxxxxxx"]
  zone            = "ru-central1-a"
  cores           = 2
  memory          = 4
  disk_size       = 20
  public_ip       = true
  ssh_keys        = ["ssh-ed25519 AAAAC3Nza... user@example.com"]
  user_data       = file("cloud-config.yaml")

  secondary_disks = [
    {
      size = 50
      type = "network-ssd"
    }
  ]

  labels = {
    env  = "production"
    role = "web"
  }
}
```

## Входные переменные

| Переменная | Описание | Тип | По умолчанию |
|------------|----------|------|--------------|
| vm_name | Базовое имя ВМ | string | - |
| vm_count | Количество ВМ | number | 1 |
| subnet_ids | Список ID подсетей | list(string) | - |
| image_id | ID образа | string | Ubuntu 24.04 LTS |
| cores | Количество ядер | number | 2 |
| memory | Объем памяти (ГБ) | number | 2 |

## Выходные данные

- `instance_ids` - ID созданных ВМ
- `external_ips` - Внешние IP-адреса
- `internal_ips` - Внутренние IP-адреса
- `fqdn` - Полные доменные имена
