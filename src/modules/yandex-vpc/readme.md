# Yandex Cloud Network Module

Модуль для создания сетевой инфраструктуры в Yandex Cloud:

- VPC сеть
- Подсети в указанных зонах
- Группу безопасности с настраиваемыми правилами

## Использование

```hcl
module "network" {
  source = "./modules/yandex-network"

  env_name = "production"
  network_description = "Production network"

  subnets = [
    {
      zone = "ru-central1-a"
      cidr = "192.168.1.0/24"
    },
    {
      zone = "ru-central1-b"
      cidr = "192.168.2.0/24"
    }
  ]

  security_group_ingress = [
    {
      protocol       = "TCP"
      description    = "Custom SSH access"
      v4_cidr_blocks = ["10.0.0.0/8"]
      port           = 22
    }
  ]
}
```

## Outputs

- `network_id` - ID созданной VPC сети
- `subnet_ids` - Map ID подсетей по зонам
- `security_group_id` - ID группы безопасности
