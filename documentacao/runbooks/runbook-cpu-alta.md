# Runbook — CPU Alta

**Projeto:** MecaniQA Tech  
**Alerta:** MecaniQA - CPU Alta (Grafana, pasta mecaniqa-alertas)  
**Regra:** `rate(process_cpu_seconds_total{job="iot-simulator"}[1m]) * 100` acima de 80 por 2 minutos  
**Objetivo:** Diagnosticar e tratar o consumo elevado de CPU do simulador IoT no Kubernetes.

## 1. Quando utilizar

Quando o alerta de CPU alta estiver ativo no Grafana ou quando o HPA indicar uso de CPU persistentemente acima do alvo de 60%.

## 2. Verificações iniciais

```powershell
kubectl get pods -n mecaniqa
kubectl top pods -n mecaniqa
kubectl get hpa -n mecaniqa
```

Confirmar se o HPA já está escalando (coluna REPLICAS maior que 1) e se o uso de CPU está acima do alvo (coluna TARGETS).

## 3. Diagnóstico

```powershell
kubectl describe hpa iot-simulator-hpa -n mecaniqa
kubectl logs deployment/iot-simulator -n mecaniqa --tail=100
kubectl get events -n mecaniqa --sort-by=.lastTimestamp
```

No Prometheus, comparar a CPU com o volume de leituras:

```promql
rate(process_cpu_seconds_total{job="iot-simulator"}[1m]) * 100
sum(rate(mecaniqa_sensor_readings_total{job="iot-simulator"}[1m]))
```

## 4. Possíveis causas

- Janela de pico (08h–08h30 e 17h–17h30) ou teste de estresse em andamento.
- Aumento de `BASE_RATE` ou `FORCE_PEAK=true` no deployment.
- Limite de CPU (250m) insuficiente para a carga.
- HPA já no máximo (5 Pods) sem conseguir absorver a carga.

## 5. Ações corretivas

1. Confirmar se o aumento está ligado a pico legítimo ou a configuração indevida (`FORCE_PEAK`).
2. Se o HPA estiver abaixo de 5 réplicas, aguardar a estabilização e acompanhar a escala.
3. Se estiver no máximo e a CPU continuar alta, solicitar autorização para revisar `maxReplicas` ou os limites de CPU.
4. Não reiniciar Pods sem avaliar a causa e o impacto.

## 6. Validação da recuperação

```powershell
kubectl top pods -n mecaniqa
kubectl get hpa -n mecaniqa
```

Confirmar CPU abaixo de 80%, Pods saudáveis e o alerta em Normal no Grafana.

## 7. Critérios de encerramento

- CPU estabilizada abaixo do limite por, no mínimo, 2 minutos.
- HPA estável e Pods em Running.
- Alerta Normal no Grafana.
- Causa e ações registradas.

## 8. Escalonamento

Se a CPU permanecer alta com o HPA no máximo, registrar horários, comandos e saídas e encaminhar ao responsável pela infraestrutura Kubernetes.
