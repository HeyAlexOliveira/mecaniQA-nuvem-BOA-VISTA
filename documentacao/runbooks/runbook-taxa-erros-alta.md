# Runbook — Taxa de Erros Alta

**Projeto:** MecaniQA Tech  
**Encontro:** 4 — Monitorando a Continuidade  
**Alerta:** MecaniQA - Taxa de Erros Alta  
**Objetivo:** Identificar, diagnosticar e tratar o aumento da taxa de erros do simulador IoT no Kubernetes.

## 1. Quando utilizar

Utilizar este procedimento quando o alerta de taxa de erros alta estiver ativo no Grafana ou quando houver aumento persistente de erros durante o processamento das leituras.

## 2. Verificações iniciais

Verificar o estado dos pods:

```powershell
kubectl get pods -n mecaniqa
```

Consultar os logs recentes do simulador:

```powershell
kubectl logs deployment/iot-simulator -n mecaniqa --tail=100
```

Verificar os eventos recentes:

```powershell
kubectl get events -n mecaniqa --sort-by=.lastTimestamp
```

Consultar o estado do deployment:

```powershell
kubectl get deployment iot-simulator -n mecaniqa
```

## 3. Diagnóstico no Prometheus

Consultar a taxa de erros por segundo:

```promql
sum(rate(mecaniqa_sensor_errors_total{job="iot-simulator"}[1m]))
```

Consultar a taxa de leituras processadas por segundo:

```promql
sum(rate(mecaniqa_sensor_readings_total{job="iot-simulator"}[1m]))
```

Calcular a porcentagem de erros em relação às leituras:

```promql
100 * sum(rate(mecaniqa_sensor_errors_total{job="iot-simulator"}[1m])) / clamp_min(sum(rate(mecaniqa_sensor_readings_total{job="iot-simulator"}[1m])), 0.000001)
```

Comparar o resultado com o limite configurado na regra do Grafana. A configuração atual utiliza 5% como limite de referência.

## 4. Possíveis causas

- Aumento de falhas no processamento das leituras.
- Sobrecarga durante picos de atividade.
- Problemas no código ou na configuração do simulador.
- Instabilidade do pod ou reinicializações.
- Erros decorrentes de uma condição anormal no ambiente de execução.

## 5. Ações corretivas

1. Verificar se o aumento de erros coincide com um teste de carga ou pico de atividade.
2. Analisar os logs para identificar mensagens de erro e sua frequência.
3. Conferir os eventos e o estado dos pods.
4. Identificar a causa antes de realizar alterações.
5. Aplicar a correção autorizada pela equipe e acompanhar novamente as métricas.
6. Evitar reinicializações sem diagnóstico, pois podem ocultar a causa original.

## 6. Validação da recuperação

Consultar novamente a porcentagem de erros no Prometheus.

Verificar se os pods continuam funcionando:

```powershell
kubectl get pods -n mecaniqa
```

Conferir os logs recentes:

```powershell
kubectl logs deployment/iot-simulator -n mecaniqa --tail=100
```

Confirmar que a taxa de erros está abaixo do limite configurado e que o alerta voltou ao estado Normal no Grafana.

## 7. Critérios de encerramento

O incidente pode ser encerrado quando:

- A taxa de erros estiver abaixo do limite estabelecido.
- O simulador estiver funcionando normalmente.
- Os logs não apresentarem novas falhas relevantes.
- O alerta estiver Normal no Grafana.
- A causa e as ações corretivas estiverem registradas.

## 8. Escalonamento

Se a taxa de erros permanecer elevada, registrar os resultados das consultas, os horários, os logs e os eventos relevantes. Encaminhar as evidências ao responsável pela aplicação ou pela infraestrutura Kubernetes.

**Observação:** a taxa de erros pode variar com o volume de leituras. Quando houver poucas ou nenhuma leitura, interpretar o resultado com cautela e verificar se as métricas estão sendo coletadas corretamente.
