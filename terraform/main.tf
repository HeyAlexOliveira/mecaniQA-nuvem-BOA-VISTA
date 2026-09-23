resource "docker_network" "mecaniqa_network" {
  name   = "${var.project_name}-network"
  driver = "bridge"
}

resource "docker_volume" "mysql_data" {
  name = "${var.project_name}-mysql-data"
}

resource "docker_volume" "redis_data" {
  name = "${var.project_name}-redis-data"
}

resource "docker_image" "api" {
  name = "${var.project_name}-java:latest"

  build {
    context    = "${path.module}/.."
    dockerfile = "Dockerfile"
  }
}

resource "docker_image" "mysql" {
  name = "${var.project_name}-mysql:latest"

  build {
    context    = "${path.module}/../mysql"
    dockerfile = "Dockerfile"
  }
}

resource "docker_image" "redis" {
  name = "${var.project_name}-redis:latest"

  build {
    context    = "${path.module}/../redis"
    dockerfile = "Dockerfile"
  }
}

resource "docker_container" "mysql" {
  name  = "${var.project_name}-mysql"
  image = docker_image.mysql.image_id

  env = [
    "MYSQL_ROOT_PASSWORD=${var.mysql_root_password}",
    "MYSQL_DATABASE=${var.mysql_database}",
    "MYSQL_USER=${var.mysql_user}",
    "MYSQL_PASSWORD=${var.mysql_password}",
  ]

  ports {
    internal = 3306
    external = var.mysql_port
  }

  volumes {
    volume_name    = docker_volume.mysql_data.name
    container_path = "/var/lib/mysql"
  }

  networks_advanced {
    name = docker_network.mecaniqa_network.name
  }

  restart = "unless-stopped"
}

resource "docker_container" "redis" {
  name  = "${var.project_name}-redis"
  image = docker_image.redis.image_id

  ports {
    internal = 6379
    external = var.redis_port
  }

  volumes {
    volume_name    = docker_volume.redis_data.name
    container_path = "/data"
  }

  networks_advanced {
    name = docker_network.mecaniqa_network.name
  }

  restart = "unless-stopped"
}

resource "docker_container" "api" {
  name  = "${var.project_name}-api"
  image = docker_image.api.image_id

  env = [
    "MYSQL_HOST=${docker_container.mysql.name}",
    "MYSQL_PORT=3306",
    "MYSQL_DATABASE=${var.mysql_database}",
    "MYSQL_USER=${var.mysql_user}",
    "MYSQL_PASSWORD=${var.mysql_password}",
    "REDIS_HOST=${docker_container.redis.name}",
    "REDIS_PORT=6379",
  ]

  ports {
    internal = 8080
    external = var.api_port
  }

  networks_advanced {
    name = docker_network.mecaniqa_network.name
  }

  depends_on = [
    docker_container.mysql,
    docker_container.redis,
  ]

  restart = "unless-stopped"
}
