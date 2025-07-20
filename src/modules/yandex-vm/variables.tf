variable "vm_name" {
  description = "Базовое имя виртуальной машины"
  type        = string
}

variable "vm_name_prefix" {
  description = "Префикс для имени виртуальной машины"
  type        = string
  default     = "vm-"
}

variable "vm_count" {
  description = "Количество создаваемых виртуальных машин"
  type        = number
  default     = 1
  validation {
    condition     = var.vm_count > 0
    error_message = "VM count must be greater than 0."
  }
}

variable "zone" {
  description = "Зона доступности"
  type        = string
  default     = "ru-central1-d"
}

variable "subnet_ids" {
  description = "Список ID подсетей для размещения ВМ"
  type        = list(string)
  validation {
    condition     = length(var.subnet_ids) > 0
    error_message = "At least one subnet ID must be specified."
  }
}

variable "security_group_ids" {
  description = "Список ID групп безопасности"
  type        = list(string)
  default     = []
}

variable "image_id" {
  description = "Идентификатор образа для ВМ"
  type        = string
  default     = "fd80j21lmqard15ciskf" # Ubuntu 24.04 LTS
}

variable "platform_id" {
  description = "Платформа виртуальной машины"
  type        = string
  default     = "standard-v3"
  validation {
    condition     = contains(["standard-v1", "standard-v2", "standard-v3"], var.platform_id)
    error_message = "Invalid platform provided."
  }
}

variable "public_ip" {
  description = "Наличие публичного IP-адреса"
  type        = bool
  default     = false
}

variable "known_internal_ip" {
  description = "Фиксированный внутренний IP-адрес"
  type        = string
  default     = ""
}

variable "cores" {
  description = "Количество ядер процессора"
  type        = number
  default     = 2
  validation {
    condition     = var.cores > 0
    error_message = "CPU cores must be greater than 0."
  }
}

variable "memory" {
  description = "Объем памяти в ГБ"
  type        = number
  default     = 2
  validation {
    condition     = var.memory > 0
    error_message = "Memory must be greater than 0."
  }
}

variable "core_fraction" {
  description = "Гарантированная доля vCPU"
  type        = number
  default     = 20
  validation {
    condition     = var.core_fraction > 0 && var.core_fraction <= 100
    error_message = "Core fraction must be between 1 and 100."
  }
}

variable "disk_size" {
  description = "Размер загрузочного диска в ГБ"
  type        = number
  default     = 10
  validation {
    condition     = var.disk_size >= 10
    error_message = "Disk size must be at least 10GB."
  }
}

variable "disk_type" {
  description = "Тип загрузочного диска"
  type        = string
  default     = "network-hdd"
  validation {
    condition     = contains(["network-hdd", "network-ssd", "network-ssd-nonreplicated"], var.disk_type)
    error_message = "Invalid disk type provided."
  }
}

variable "preemptible" {
  description = "Флаг прерываемой ВМ"
  type        = bool
  default     = true
}

variable "user_data" {
  description = "Cloud-init конфигурация"
  type        = string
  default     = null
}

variable "ssh_keys" {
  description = "SSH-ключи для доступа к ВМ"
  type        = list(string)
  default     = []
}

variable "labels" {
  description = "Стандартные метки для ВМ"
  type        = map(string)
  default     = {
    terraform = "true"
  }
}

variable "custom_labels" {
  description = "Пользовательские метки для ВМ"
  type        = map(string)
  default     = {}
}

variable "scheduling_policy" {
  description = "Политика планирования ВМ"
  type = object({
    preemptible = optional(bool)
  })
  default = null
}

variable "metadata" {
  description = "Метаданные ВМ"
  type        = map(string)
  default     = {}
}

variable "secondary_disk_ids" {
  description = "Список ID существующих дисков для подключения к ВМ"
  type        = list(string)
  default     = []
}

variable "create_before_destroy" {
  description = "Создавать новую ВМ перед уничтожением старой"
  type        = bool
  default     = false
}

variable "allow_stopping_for_update" {
  description = "Разрешить остановку ВМ для обновления"
  type        = bool
  default     = true
}