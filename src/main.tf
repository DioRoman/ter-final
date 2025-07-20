module "yandex-vpc" {
  source       = "./modules/yandex-vpc"
  env_name     = var.web[0].env_name
  subnets = [
    { zone = var.vpc_default_zone[2], cidr = var.vpc_default_cidr[0] }
  ]
  security_groups = [
    {
      name        = "web"
      description = "Security group for web servers"
      ingress_rules = [
        {
          protocol    = "TCP"
          port        = 80
          description = "HTTP access"
          cidr_blocks = ["0.0.0.0/0"]
        },
        {
          protocol    = "TCP"
          port        = 443
          description = "HTTPS access"
          cidr_blocks = ["0.0.0.0/0"]
        },
        {
          protocol    = "TCP"
          port        = 22
          description = "SSH access"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ],
    egress_rules = [
        {
            protocol    = "ANY"
            description = "Allow all outbound traffic"
            cidr_blocks = ["0.0.0.0/0"]
        }
      ]
    },
  ]
}

module "web-vm" {
  source              = "./modules/yandex-vm"
  vm_name             = var.web[0].instance_name 
  vm_count            = var.web[0].instance_count
  zone                = var.vpc_default_zone[2]
  subnet_ids          = module.yandex-vpc.subnet_ids
  image_id            = data.yandex_compute_image.ubuntu.id
  platform_id         = var.web[0].platform_id
  cores               = var.web[0].cores
  memory              = var.web[0].memory
  disk_size           = var.web[0].disk_size 
  public_ip           = var.web[0].public_ip
  security_group_ids  = [module.yandex-vpc.security_group_ids["web"]]
  
  labels = {
    env  = var.web[0].env_name
    role = var.web[0].role
  }

  metadata = {
    user-data = data.template_file.cloudinit.rendered
    serial-port-enable = local.serial-port-enable
  }  
}

data "template_file" "cloudinit" {
  template = file("./cloud-init.yml")
    vars = {
    ssh_public_key     = file(var.vm_ssh_root_key)
  }
}

data "yandex_compute_image" "ubuntu" {
  family = var.vm_web_image_family
}