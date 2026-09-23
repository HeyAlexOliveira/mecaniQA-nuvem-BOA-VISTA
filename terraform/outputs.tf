output "network_name" {
  description = "Nome da rede Docker criada"
  value       = docker_network.mecaniqa_network.name
}

output "api_container_name" {
  value = docker_container.api.name
}

output "api_url" {
  description = "URL local da API Java"
  value       = "http://localhost:${var.api_port}"
}

output "mysql_container_name" {
  value = docker_container.mysql.name
}

output "redis_container_name" {
  value = docker_container.redis.name
}
