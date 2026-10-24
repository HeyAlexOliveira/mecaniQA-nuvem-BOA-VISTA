# Métricas de Continuidade — SLA, SLO, SLI, RTO e RPO

**Projeto:** MecaniQA Tech — OAT 2 (Monitorando a Continuidade)  
**Equipe:** BOA VISTA

## 1. Definições

| Sigla | Significado | Meta adotada |
| --- | --- | --- |
| SLA | Acordo de nível de serviço (compromisso com o cliente Enterprise) | Disponibilidade mensal de 99,9% |
| SLO | Meta interna que sustenta o SLA | Disponibilidade ≥ 99,9%; taxa de erros < 5%; latência p95 < 100 ms |
| SLI | Indicador medido no Prometheus/Grafana | Ver seção 2 |
| RTO | Tempo-alvo para restaurar o serviço | 30 minutos |
| RPO | Perda máxima de dados aceitável | 15 minutos |

## 2. Indicadores (SLIs)

| Indicador | Consulta PromQL |
| --- | --- |
| Disponibilidade | `avg_over_time(up{job="iot-simulator"}[5m])` |
| Taxa de erros (%) | `100 * sum(rate(mecaniqa_sensor_errors_total[1m])) / clamp_min(sum(rate(mecaniqa_sensor_readings_total[1m])), 0.000001)` |
| Latência p95 | `histogram_quantile(0.95, sum(rate(mecaniqa_reading_processing_seconds_bucket[5m])) by (le))` |
| Vazão (leituras/s) | `sum(rate(mecaniqa_sensor_readings_total[1m]))` |

Valor observado de p95 durante os testes: cerca de 43 ms.

## 3. Orçamento de indisponibilidade (99,9%)

| Período | Indisponibilidade máxima |
| --- | --- |
| Ano (365 dias) | 8 h 45 min 36 s |
| Mês (30 dias) | 43 min 12 s |
| Semana | 10 min 4 s |

Exemplo: uma queda de 45 minutos consome cerca de 8,6% do orçamento anual, mas ultrapassa o orçamento mensal (43 min 12 s) e, portanto, descumpre o SLA daquele mês.

## 4. Relação com os alarmes

| Alarme | Limite | Runbook |
| --- | --- | --- |
| CPU Alta | > 80% por 2 min | runbooks/runbook-cpu-alta.md |
| Memória Alta | > 80% por 2 min | runbooks/runbook-memoria-alta.md |
| Taxa de Erros Alta | > 5% por 2 min | runbooks/runbook-taxa-erros-alta.md |
| Leituras Baixas | < 0,2 leitura/s por 2 min | runbooks/runbook-leituras-baixas.md |

## 5. Continuidade (RTO e RPO)

- **RTO 30 min:** o Kubernetes recria Pods com falha automaticamente; para falha maior (cluster/região), reaplicar os manifestos em `k8s/` e `k8s/monitoring/`.
- **RPO 15 min:** MySQL e Redis usam volumes persistentes; o Redis grava AOF a cada segundo. Para sustentar o RPO de 15 min no MySQL é necessário implantar backup periódico (ver próximos passos).

## 6. Evidências

Capturas e logs do teste de estresse estão na pasta `evidencias/`.
