module "yandex_vm" {
  source = "./modules/yandex-vm"

  vm_name    = "my-vm"
  vm_count   = 2
  zone       = "ru-central1-a"
  subnet_ids = yandex_vpc_subnet.my-subnet.id
  image_id   = "fd87va5cc00gaq2f5qfb" # Ubuntu 20.04
  cores      = 4
  memory     = 4
  disk_size  = 30
  disk_type  = "network-ssd"
  public_ip  = true
  user_data  = file("cloud-config.yaml")

  labels = {
    env  = "production"
    role = "web-server"
  }
}
