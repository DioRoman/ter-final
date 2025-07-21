# Документация на Terraform-модуль для создания VPC на Yandex Cloud

## Описание

Модуль предназначен для быстрого и стандартизированного создания сетевой инфраструктуры в Yandex Cloud. Он создает виртуальную сеть (VPC), набор подсетей и групп безопасности с произвольными правилами.

## Необходимые зависимости

- **Terraform**: >= 1.3.0
- **Провайдер**: yandex-cloud/yandex >= 0.85.0

```hcl
terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.85.0"
    }
  }
  required_version = ">= 1.3.0"
}
```


## Входные переменные

| Имя | Тип | Описание | Обязательная | Значение по умолчанию |
| :-- | :-- | :-- | :-- | :-- |
| env_name | string | Имя окружения (используется в названиях ресурсов) | Да | – |
| network_description | string | Описание создаваемой сети | Нет | null |
| labels | map(string) | Метки для всех ресурсов | Нет | {} |
| subnets | list(object) | Список подсетей для создания | Нет | [] |
| security_groups | list(object) | Перечень групп безопасности с правилами | Нет | [] |

#### Пример структуры `subnets`

```hcl
subnets = [
  {
    zone        = "ru-central1-a"
    cidr        = "10.0.1.0/24"
    description = "main subnet"
  },
]
```


#### Пример структуры `security_groups`

```hcl
security_groups = [
  {
    name        = "main-sg"
    description = "Main security group"
    ingress_rules = [
      {
        protocol       = "TCP"
        description    = "SSH"
        port           = 22
        cidr_blocks    = ["0.0.0.0/0"]
      }
    ]
    egress_rules = [
      {
        protocol       = "ANY"
        description    = "Allow all outbound"
      }
    ]
  }
]
```


## Выходные значения

| Имя | Описание |
| :-- | :-- |
| network_id | ID созданной VPC-сети |
| network_name | Имя созданной VPC-сети |
| subnet_ids | Список ID всех созданных подсетей |
| security_group_ids | Map с ID созданных групп безопасности (ключ - имя группы) |

## Пример использования

```hcl
module "vpc" {
  source = "./modules/vpc"

  env_name            = "stage"
  network_description = "Сеть для stage-окружения"
  labels = {
    project   = "sample"
    terraform = "true"
  }

  subnets = [
    {
      zone        = "ru-central1-a"
      cidr        = "10.0.10.0/24"
      description = "Subnet in ru-central1-a"
    },
    {
      zone        = "ru-central1-b"
      cidr        = "10.0.20.0/24"
    }
  ]

  security_groups = [
    {
      name        = "web"
      description = "Web SG"
      ingress_rules = [
        {
          protocol     = "TCP"
          port         = 80
          cidr_blocks  = ["0.0.0.0/0"]
        }
      ]
      egress_rules = [
        {
          protocol     = "ANY"
          description  = "Allow all"
        }
      ]
    }
  ]
}
```


## Описание ресурсов

- **yandex_vpc_network.network** — создаёт виртуальную сеть.
- **yandex_vpc_subnet.subnets** — создает подсети по списку с поддержкой разных зон.
- **yandex_vpc_security_group.sg** — создаёт группы безопасности с произвольными ingress/egress правилами.


## Авторство

Разработано для инфраструктуры на базе Yandex Cloud с использованием Terraform.

## Примечания

- Все ресурсы маркируются переданными метками (`labels`).
- Защита сетевого периметра реализуется через переменную `security_groups`, поддерживается добавление комплексных правил доступа.

---