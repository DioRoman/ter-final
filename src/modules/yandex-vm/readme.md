# Документация на Terraform-модуль для создания виртуальных машин в Yandex Cloud

## Описание

Модуль позволяет создавать одну или несколько виртуальных машин (**Yandex Compute Instance**) в облаке Yandex.Cloud с настройкой ресурсов, дисков, сети, групп безопасности и других параметров.

## Требования

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

| Переменная | Тип | Описание | Обязательная | Значение по умолчанию |
| :-- | :-- | :-- | :-- | :-- |
| vm_name | string | Базовое имя виртуальной машины | да | – |
| vm_name_prefix | string | Префикс для имени ВМ | нет | "vm-" |
| vm_count | number | Число ВМ | нет | 1 |
| zone | string | Зона размещения | нет | "ru-central1-d" |
| subnet_ids | list(string) | Список ID подсетей | да | – |
| security_group_ids | list(string) | Список ID групп безопасности | нет | [] |
| image_id | string | Идентификатор образа | нет | "fd80j21lmqard15ciskf" |
| platform_id | string | Аппаратная платформа | нет | "standard-v3" |
| public_ip | bool | Назначить внешний IP | нет | false |
| known_internal_ip | string | Фиксированный внутренний IP | нет | "" |
| cores | number | Ядер vCPU | нет | 2 |
| memory | number | Объем ОЗУ (ГБ) | нет | 2 |
| core_fraction | number | Доля CPU (%) | нет | 20 |
| disk_size | number | Размер загрузочного диска (ГБ) | нет | 10 |
| disk_type | string | Тип загрузочного диска | нет | "network-hdd" |
| preemptible | bool | Прерываемая ВМ | нет | true |
| user_data | string | Cloud-init конфиг | нет | null |
| ssh_keys | list(string) | SSH ключи | нет | [] |
| labels | map(string) | Стандартные метки ВМ | нет | { terraform = "true" } |
| custom_labels | map(string) | Пользовательские метки | нет | {} |
| scheduling_policy | object | Опции планирования | нет | null |
| metadata | map(string) | Метаданные ВМ | нет | {} |
| secondary_disk_ids | list(string) | ID вторичных дисков | нет | [] |
| create_before_destroy | bool | Создавать до удаления предыдущей | нет | false |
| allow_stopping_for_update | bool | Остановка ВМ для обновления | нет | true |

### Пример переменных

```hcl
vm_name      = "myapp"
vm_count     = 2
subnet_ids   = ["e9b1v9nk8e9bd0rpnrrj", "e9b1u2nm8e9qd2rpn00q"]
security_group_ids = ["enpskndw0f123a6g43rt"]
cores        = 2
memory       = 4
labels       = {
  environment = "production"
}
custom_labels = {
  app = "backend"
}
```


## Выходные значения

| Выход | Описание |
| :-- | :-- |
| instance_ids | Список ID созданных ВМ |
| instance_names | Список имён созданных ВМ |
| external_ips | Список внешних IP-адресов ВМ |
| internal_ips | Список внутренних IP-адресов ВМ |
| network_interfaces | Информация по сетевым интерфейсам ВМ |
| boot_disks | Информация о загрузочных дисках всех ВМ |

## Пример использования

```hcl
module "vm" {
  source              = "./modules/compute-instance"
  vm_name             = "app"
  vm_count            = 2
  subnet_ids          = ["subnet-1-id", "subnet-2-id"]
  security_group_ids  = ["sg-id1", "sg-id2"]
  cores               = 2
  memory              = 4
  disk_size           = 20
  disk_type           = "network-ssd"
  public_ip           = true
  labels = {
    environment = "dev"
    terraform   = "true"
  }
  custom_labels = {
    role = "app"
  }
  ssh_keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQ..."
  ]
}
```


## Особенности работы

- **Именование:** если создаётся несколько ВМ, к имени и hostname добавляется порядковый номер (например, `app-1`, `app-2`).
- **Сети и безопасность:** требуется минимум одна подсеть. Можно указывать zero или несколько групп безопасности.
- **Ресурсы и диски:** поддерживаются вторичные диски через IDs уже существующих дисков.
- **IP-адреса:** возможность назначения публичного и/или статического приватного IP.
- **Метаданные и cloud-init:** поддержка user-data и передачи любых meta-данных.
- **Гибкость:** модуль позволяет задавать большинство стандартных и дополнительных опций Yandex Cloud Compute Instance.
- **Валидация:** реализованы проверки на валидность типов, диапазонов значений, платформы, типа диска.


## Рекомендации

- Для полноценной работы доступа по SSH требуется указать корректные `ssh_keys` и разрешить правилами группу безопасности нужные порты.
- Для изменений конфигурации ВМ может потребоваться её остановка — опция управляется через `allow_stopping_for_update`.
- Для устойчивости и безотказного обновления используйте флаг `create_before_destroy` при изменении параметров ВМ, критичных для рабочих нагрузок.


## Авторы

Модуль разработан для использования в инфраструктуре Yandex.Cloud и легко кастомизируется под различные сценарии эксплуатации.