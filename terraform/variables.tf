variable "project_name" {
  description = "Prefixo usado para nomear os recursos provisionados"
  type        = string
  default     = "mecaniqa-boa-vista"
}

variable "mysql_root_password" {
  description = "Senha do usuario root do MySQL"
  type        = string
  default     = "root123"
  sensitive   = true
}

variable "mysql_database" {
  description = "Nome do banco de dados da aplicacao"
  type        = string
  default     = "mecaniqa"
}

variable "mysql_user" {
  description = "Usuario de aplicacao do MySQL"
  type        = string
  default     = "mecaniqa"
}

variable "mysql_password" {
  description = "Senha do usuario de aplicacao do MySQL"
  type        = string
  default     = "mecaniqa123"
  sensitive   = true
}

variable "api_port" {
  description = "Porta exposta pela API Java no host"
  type        = number
  default     = 8080
}

variable "mysql_port" {
  description = "Porta exposta pelo MySQL no host"
  type        = number
  default     = 3306
}

variable "redis_port" {
  description = "Porta exposta pelo Redis no host"
  type        = number
  default     = 6379
}
