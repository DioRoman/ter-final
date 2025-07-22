variable "web" {
  type = list(
     object({ env_name = string, instance_name = string, instance_count = number, public_ip = bool, platform_id = string,
     cores = number, memory = number, disk_size = number, role= string }))
  default = ([ 
    { 
    env_name          = "production",
    instance_name     = "web", 
    instance_count    = 1, 
    public_ip         = true,
    platform_id       = "standard-v3",
    cores             = 2,
    memory            = 2,
    disk_size         = 10,
    role              = "web"    
  }])
}