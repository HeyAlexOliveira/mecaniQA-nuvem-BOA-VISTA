# mecaniQA-nuvem-boa-vista

Projeto da **MecâniQA Tech** — OAT 1 (Cloud/DevOps: Docker, Compose, Terraform e Kubernetes) e OAT 2 (Monitorando a Continuidade: observabilidade, autoscaling e continuidade de negócios).

## Contexto

A MecâniQA Tech é uma startup que fornece um SaaS de gestão e diagnóstico automotivo para oficinas mecânicas. A aplicação principal é escrita em Java, usa **MySQL** para dados transacionais e **Redis** para dados em alta velocidade (cache/NoSQL).

Neste desafio, a equipe **BOA VISTA** atuou como Engenheiros Cloud/DevOps, entregando:

- **Containers isolados** (Dockerfile próprio) para a API Java, o MySQL e o Redis;
- **Orquestração local** com `docker-compose.yml` (rede interna + persistência de dados);
- **Infraestrutura como código** com **Terraform** (provisionamento declarativo da mesma stack);
- **Camada de Controle** com **Kubernetes**: Pods, Deployments, Services, ConfigMap, Secret e volumes persistentes, monitorados com **K9s**.

## Equipe — BOA VISTA

| Nome completo               |
| --------------------------- |
| Alex Oliveira Santos        |
| Alice Gomes Aragão          |
| Ana Clara Ribeiro da Silva  |
| Lorran Edley Matos Ribeiro  |
| Rodrigo dos Anjos Lamartine |

## Estrutura do repositório

```
.
├── Dockerfile
├── Main.java
├── docker-compose.yml
├── mecaniQA_oat1_boa-vista.pdf
├── .gitignore
├── .dockerignore
├── mysql/
│   ├── Dockerfile
│   └── init.sql
├── redis/
│   ├── Dockerfile
│   └── redis.conf
├── terraform/
│   ├── versions.tf
│   ├── variables.tf
│   ├── main.tf
│   ├── outputs.tf
│   └── terraform.tfvars.example
└── k8s/
    ├── namespace.yaml
    ├── configmap.yaml
    ├── secret.yaml
    ├── mysql-init-configmap.yaml
    ├── mysql-pvc.yaml
    ├── redis-pvc.yaml
    ├── java-deployment.yaml
    ├── java-service.yaml
    ├── mysql-deployment.yaml
    ├── mysql-service.yaml
    ├── redis-deployment.yaml
    └── redis-service.yaml
```

Obs.: o Docker Compose e o Terraform usam as mesmas portas no host (`8080`, `3306` e `6379`), então rode um por vez. Rode `docker compose down` antes do `terraform apply` e `terraform destroy` antes de subir o Compose de novo. O Kubernetes usa a porta `30080` e não conflita.

## Como rodar — Docker Compose

Pré-requisito: Docker e Docker Compose instalados.

```bash
docker compose up --build -d
docker compose ps
docker compose logs -f api
```

Isso sobe 3 containers (`mecaniqa-api`, `mecaniqa-mysql`, `mecaniqa-redis`) na rede `mecaniqa-network`, com dados persistidos nos volumes nomeados `mysql_data` e `redis_data`.

Para encerrar:

```bash
docker compose down
# remove os volumes tambem:
docker compose down -v
```

## Como rodar — Terraform

Pré-requisito: Terraform >= 1.5 e Docker em execução.

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
```

O Terraform provisiona, via provider `kreuzwerker/docker`, a mesma topologia do `docker-compose.yml`: rede, volumes de dados e os 3 containers. As três imagens são construídas a partir dos Dockerfiles do próprio repositório, incluindo a API Java pela raiz do projeto.

Para destruir o ambiente:

```bash
terraform destroy
```

## Como rodar — Kubernetes

Pré-requisito: cluster local (Docker Desktop com Kubernetes habilitado, Minikube ou Kind) e `kubectl` configurado.

As imagens da **API Java** e do **Redis** são construídas localmente, e por isso os manifests usam `imagePullPolicy: Never`. O **MySQL** usa a imagem oficial `mysql:8.0` (baixada do Docker Hub), com o `init.sql` injetado via ConfigMap; portanto **não** é necessário buildar a imagem `mysql/` para o Kubernetes.

```bash
# build das imagens (API e Redis)
docker build -t mecaniqa-boa-vista-java:latest .
docker build -t mecaniqa-boa-vista-redis:latest ./redis

# Docker Desktop nao precisa carregar as imagens
# Minikube:
minikube image load mecaniqa-boa-vista-java:latest
minikube image load mecaniqa-boa-vista-redis:latest
# Kind:
kind load docker-image mecaniqa-boa-vista-java:latest mecaniqa-boa-vista-redis:latest

# manifests
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/mysql-init-configmap.yaml
kubectl apply -f k8s/secret.yaml
kubectl apply -f k8s/mysql-pvc.yaml
kubectl apply -f k8s/redis-pvc.yaml
kubectl apply -f k8s/mysql-deployment.yaml -f k8s/mysql-service.yaml
kubectl apply -f k8s/redis-deployment.yaml -f k8s/redis-service.yaml
kubectl apply -f k8s/java-deployment.yaml -f k8s/java-service.yaml

# monitorar
k9s -n mecaniqa
```

> O `mysql-init-configmap.yaml` contém o mesmo `init.sql` da pasta `mysql/` e é montado em `/docker-entrypoint-initdb.d/`, garantindo a inicialização do banco no Kubernetes. Ele deve ser aplicado **antes** do `mysql-deployment.yaml`. O script só é executado quando o diretório de dados ainda está vazio.

A API fica acessível via NodePort `30080` (em Docker Desktop, normalmente em `http://localhost:30080`; no Minikube, com `minikube service java-service -n mecaniqa`). Em qualquer cluster também funciona o port-forward:

```bash
kubectl port-forward -n mecaniqa deployment/mecaniqa-java 8080:8080
# em outro terminal: curl http://127.0.0.1:8080
```

## Validação rápida

Após subir o ambiente, use os comandos abaixo para conferir os principais recursos:

```bash
docker compose ps

terraform output

kubectl get pods -n mecaniqa
kubectl get services -n mecaniqa
kubectl get pvc -n mecaniqa

k9s -n mecaniqa
```

## Persistência de dados

- **Docker Compose**: volumes nomeados `mysql_data` e `redis_data`.
- **Terraform**: `docker_volume` `mecaniqa-boa-vista-mysql-data` e `mecaniqa-boa-vista-redis-data` (prefixo definido pela variável `project_name`), montados nos containers.
- **Kubernetes**: `PersistentVolumeClaim` (`mysql-pvc`, `redis-pvc`) montados em `/var/lib/mysql` e `/data`, respectivamente. O Redis está configurado com AOF (`appendonly yes`) para maior durabilidade.

## Rede

- **Docker Compose**: rede bridge dedicada `mecaniqa-network`, com resolução DNS interna pelos nomes dos serviços (`mysql`, `redis`, `api`).
- **Kubernetes**: comunicação entre Pods via `Service` (`mysql-service`, `redis-service`), com nomes resolvidos pelo DNS interno do cluster e injetados na API via `ConfigMap`.

---

# OAT 2 — Monitorando a Continuidade

## Contexto

Oficinas enviam milhares de leituras de sensores IoT em horários de pico (08h e 17h) e o cluster operava como uma "caixa preta". Clientes Enterprise exigem **99,9%** de disponibilidade. Nesta etapa a equipe instrumentou o simulador de sensores (Python), subiu **Prometheus** e **Grafana** no Kubernetes, criou **4 dashboards** e **4 alarmes**, configurou o **HPA** e documentou **runbooks** e as métricas de continuidade.

## Estrutura adicionada na OAT 2

```
.
├── mecaniQA_oat2_boa-vista.pdf          # apresentação
├── iot-simulator/                       # simulador Python instrumentado (prometheus_client)
├── k8s/
│   ├── iot-simulator-deployment.yaml    # Deployment + Service (metrics :8000)
│   └── monitoring/
│       ├── namespace.yaml
│       ├── prometheus-*.yaml            # ConfigMap, Deployment, Service (NodePort 30090)
│       ├── hpa/iot-simulator-hpa.yaml   # HPA autoscaling/v2 (1-5 Pods, CPU 60%, memória 70%)
│       └── grafana/
│           ├── grafana-datasource.yaml            # datasource Prometheus (uid: prometheus)
│           ├── grafana-dashboards-provider.yaml   # provisionamento de dashboards
│           ├── grafana-dashboards-configmap.yaml  # 4 dashboards (CPU, Memória, Erros, Sucessos)
│           ├── grafana-alert-rules.yaml           # 4 alarmes provisionados como código
│           ├── grafana-deployment.yaml / grafana-service.yaml
│           └── dashboards/*.json                  # JSON originais exportados
├── documentacao/
│   ├── metricas-continuidade.md         # SLA, SLO, SLI, RTO e RPO
│   └── runbooks/                        # um runbook por alarme (4)
└── evidencias/                          # prints e logs do teste de estresse
```

## Métricas customizadas do simulador

| Métrica | Tipo | Descrição |
| --- | --- | --- |
| `mecaniqa_sensor_readings_total` | Counter | Leituras processadas com sucesso |
| `mecaniqa_sensor_errors_total` | Counter | Falhas de leitura |
| `mecaniqa_reading_processing_seconds` | Histogram | Tempo de processamento por leitura |
| `mecaniqa_peak_window_active` | Gauge | 1 durante a janela de pico |
| `mecaniqa_simulated_rate_per_second` | Gauge | Taxa simulada atual |

## Como rodar — Monitoramento (Kubernetes)

Pré-requisitos: cluster local com Kubernetes (Docker Desktop, Minikube ou Kind), `kubectl` e **metrics-server** ativo (necessário para o HPA e para `kubectl top`).

```bash
# 1) imagem do simulador (Minikube: minikube image load ... | Kind: kind load docker-image ...)
docker build -t mecaniqa-boa-vista-iot-simulator:latest ./iot-simulator

# 2) aplicacao
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/iot-simulator-deployment.yaml

# 3) Prometheus
kubectl apply -f k8s/monitoring/namespace.yaml
kubectl apply -f k8s/monitoring/prometheus-configmap.yaml
kubectl apply -f k8s/monitoring/prometheus-deployment.yaml -f k8s/monitoring/prometheus-service.yaml

# 4) Grafana (datasource, dashboards e alarmes provisionados)
kubectl apply -f k8s/monitoring/grafana/grafana-datasource.yaml
kubectl apply -f k8s/monitoring/grafana/grafana-dashboards-provider.yaml
kubectl apply -f k8s/monitoring/grafana/grafana-dashboards-configmap.yaml
kubectl apply -f k8s/monitoring/grafana/grafana-alert-rules.yaml
kubectl apply -f k8s/monitoring/grafana/grafana-deployment.yaml -f k8s/monitoring/grafana/grafana-service.yaml

# 5) HPA
kubectl apply -f k8s/monitoring/hpa/iot-simulator-hpa.yaml
```

Acesso:

```bash
kubectl port-forward -n monitoring service/prometheus-service 9090:9090   # http://localhost:9090
kubectl port-forward -n monitoring service/grafana-service 3000:3000      # http://localhost:3000 (admin / admin)
```

> O `grafana-alert-rules.yaml` é opcional para o Grafana subir: se ele não for aplicado, o Grafana inicia normalmente e as regras podem ser criadas pela interface. Sem volume persistente, dados criados só pela interface se perdem ao reiniciar o Pod; por isso dashboards e alarmes ficam versionados neste repositório.

## Dashboards (4)

CPU (`rate(process_cpu_seconds_total[1m]) * 100`), Memória (`process_resident_memory_bytes`), Erros (taxa de erros em %) e Sucessos (leituras por segundo).

## Alarmes (4)

| Alarme | Tipo | Condição | Runbook |
| --- | --- | --- | --- |
| CPU Alta | Infraestrutura | > 80% por 2 min | `documentacao/runbooks/runbook-cpu-alta.md` |
| Memória Alta | Infraestrutura | > 80% do limite (107374182 bytes) por 2 min | `documentacao/runbooks/runbook-memoria-alta.md` |
| Taxa de Erros Alta | Aplicação | > 5% por 2 min | `documentacao/runbooks/runbook-taxa-erros-alta.md` |
| Leituras Baixas | Aplicação | < 0,2 leitura/s por 2 min | `documentacao/runbooks/runbook-leituras-baixas.md` |

## HPA e teste de estresse

HPA `autoscaling/v2` no Deployment `iot-simulator`: mínimo 1 Pod, máximo 5, alvo de CPU 60% e de memória 70%.

Para gerar carga, ative o modo pico do simulador (taxa base x multiplicador) e acompanhe o HPA:

```bash
kubectl set env deployment/iot-simulator FORCE_PEAK=true -n mecaniqa
kubectl get hpa -n mecaniqa -w
kubectl get pods -n mecaniqa -w

# encerrar o teste
kubectl set env deployment/iot-simulator FORCE_PEAK=false -n mecaniqa
```

Resultado observado: CPU chegou a 114% do alvo, o HPA escalou para 5 réplicas, o alarme de Taxa de Erros passou de Pending para Alerting e, ao normalizar a carga, o HPA voltou a 1 réplica. Prints e logs em `evidencias/`.

## Continuidade de negócios

SLA, SLO, SLI, RTO e RPO estão definidos em `documentacao/metricas-continuidade.md` (meta de 99,9%: 8 h 45 min 36 s de indisponibilidade por ano, 43 min 12 s por mês).
