terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.85.0"
    }
  }
  required_version = ">= 1.3.0"
}

resource "yandex_compute_instance" "vm" {
  count       = var.vm_count
  name        = var.vm_count > 1 ? "${var.vm_name}-${count.index + 1}" : var.vm_name
  hostname    = var.vm_count > 1 ? "${var.vm_name}-${count.index + 1}" : var.vm_name
  platform_id = var.platform_id
  zone        = var.zone
  labels      = merge(var.labels, var.custom_labels)

  resources {
    cores         = var.cores
    memory        = var.memory
    core_fraction = var.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = var.disk_size
      type     = var.disk_type
    }
  }

  dynamic "secondary_disk" {
    for_each = var.secondary_disk_ids
    content {
      disk_id = secondary_disk.value
    }
  }

  network_interface {
    subnet_id          = element(var.subnet_ids, count.index)
    security_group_ids = var.security_group_ids
    nat                = var.public_ip
    ip_address         = var.known_internal_ip != "" ? var.known_internal_ip : null
  }

  metadata = {
    for k, v in var.metadata : k => v
  }

  scheduling_policy {
    preemptible = try(var.scheduling_policy.preemptible, var.preemptible)
  }

  allow_stopping_for_update = true
}