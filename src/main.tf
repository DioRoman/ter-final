# Создание сетей, подсетей и групп безопасности

module "yandex-vpc" {
  source       = "./modules/yandex-vpc"
  env_name     = var.web[0].env_name
  subnets = [
    { zone = var.vpc_default_zone[0], cidr = var.vpc_default_cidr[1] }
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
        },
        {
          protocol    = "TCP"
          port        = 8090
          description = "HTTP access"
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

# Создание VM
module "web-vm" {
  source              = "./modules/yandex-vm"
  vm_name             = var.web[0].instance_name 
  vm_count            = var.web[0].instance_count
  zone                = var.vpc_default_zone[0]
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

  depends_on = [
  module.yandex-vpc,
  module.mysql,
  yandex_mdb_mysql_database.my_db,
  yandex_mdb_mysql_user.admin_user
  ]
}

# Инициализация 
data "template_file" "cloudinit" {
  template = file("./cloud-init.yml")
    vars = {
    ssh_public_key     = file(var.vm_ssh_root_key)
    mysql_host    = module.mysql.fqdn
    mysql_database = yandex_mdb_mysql_database.my_db.name
    mysql_user    = yandex_mdb_mysql_user.admin_user.name
    mysql_password = data.yandex_lockbox_secret_version.mysql_password_data.entries[0].text_value
  }
}

# Получение id образа Ubuntu
data "yandex_compute_image" "ubuntu" {
  family = var.vm_web_image_family
}

# Создание кластера MYSQL
module "mysql" {
  source = "github.com/terraform-yacloud-modules/terraform-yandex-mdb-mysql?ref=v1.20.0"

  network_id     = module.yandex-vpc.network_id        
  subnet_zones   = [var.vpc_default_zone[0]]  
  subnet_id      = module.yandex-vpc.subnet_ids
  name           = "dio-mysql-cluster"
  version_sql    = "8.0"
  resource_preset_id = "b1.medium"
  disk_type_id   = "network-hdd"
  disk_size      = 10
  ha             = false
  assign_public_ip = false

  access = {
    web_sql = false
  }

  performance_diagnostics = {
    enabled = false
  }

  backup_window_start = null
  deletion_protection = false
  
  depends_on = [
  module.yandex-vpc
  ]

}

# Генерация пароля
resource "random_password" "db_password" {
  length  = 16
  special = true
  numeric = true
  upper   = true
  lower   = true
}

# Создание секрета в Lockbox

resource "yandex_lockbox_secret" "mysql_password_secret" {
  name       = "mysql-password-secret"
  folder_id  = var.folder_id
}

# Создание версии секрета в Lockbox
resource "yandex_lockbox_secret_version" "mysql_password_version" {
  secret_id = yandex_lockbox_secret.mysql_password_secret.id

  entries {
    key        = "password"
    text_value = random_password.db_password.result
  }
}

# Получение секрета и версии секрета в Lockbox
data "yandex_lockbox_secret_version" "mysql_password_data" {
  secret_id  = yandex_lockbox_secret.mysql_password_secret.id
  version_id = yandex_lockbox_secret_version.mysql_password_version.id
}

# Создание базы данных MYSQL

resource "yandex_mdb_mysql_database" "my_db" {
  cluster_id = module.mysql.id
  name       = "dio-db"
}

# Создание пользователя MYSQL
resource "yandex_mdb_mysql_user" "admin_user" {
  cluster_id = module.mysql.id
  name       = "dio"
  password = data.yandex_lockbox_secret_version.mysql_password_data.entries[0].text_value
  permission {
    database_name = yandex_mdb_mysql_database.my_db.name
    roles         = ["ALL"]
  }
}
