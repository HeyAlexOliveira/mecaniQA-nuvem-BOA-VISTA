# Runbook — Leituras Baixas

**Projeto:** MecaniQA Tech  
**Encontro:** 4 — Monitorando a Continuidade  
**Alerta:** MecaniQA - Leituras Baixas  
**Objetivo:** Identificar e corrigir a redução anormal na quantidade de leituras processadas pelo simulador IoT.

## 1. Quando utilizar

Utilizar este procedimento quando o alerta de leituras baixas estiver ativo no Grafana ou quando a taxa de leituras estiver abaixo do limite estabelecido.

## 2. Verificações iniciais

Verificar o estado dos pods:

```powershell
kubectl get pods -n mecaniqa
```

Consultar o deployment:

```powershell
kubectl get deployment iot-simulator -n mecaniqa
```

Verificar o consumo de recursos:

```powershell
kubectl top pods -n mecaniqa
```

Consultar os logs recentes:

```powershell
kubectl logs deployment/iot-simulator -n mecaniqa --tail=100
```

## 3. Diagnóstico no Prometheus

Consultar a taxa de leituras por segundo:

```promql
sum(rate(mecaniqa_sensor_readings_total{job="iot-simulator"}[1m]))
```

Consultar a taxa de erros por segundo:

```promql
sum(rate(mecaniqa_sensor_errors_total{job="iot-simulator"}[1m]))
```

Verificar se as métricas estão sendo coletadas:

```promql
up{job="iot-simulator"}
```

A regra de leituras baixas utiliza como referência uma taxa inferior a 0,2 leitura por segundo. Confirmar esse limite na configuração atual do Grafana.

## 4. Possíveis causas

- Interrupção ou falha no simulador.
- Pod indisponível ou reiniciando.
- Redução intencional da atividade de simulação.
- Sobrecarga ou falta de recursos.
- Falha na coleta ou exposição das métricas pelo Prometheus.

## 5. Ações corretivas

1. Verificar se o simulador está em execução.
2. Conferir os logs e eventos para identificar falhas.
3. Confirmar se a redução de leituras é esperada ou representa uma anormalidade.
4. Verificar se o Prometheus está coletando as métricas corretamente.
5. Se houver falha no pod, investigar a causa antes de reiniciar ou alterar o deployment.
6. Aplicar somente as correções necessárias e autorizadas pela equipe.

## 6. Validação da recuperação

Verificar os pods:

```powershell
kubectl get pods -n mecaniqa
```

Consultar novamente a taxa de leituras no Prometheus:

```promql
sum(rate(mecaniqa_sensor_readings_total{job="iot-simulator"}[1m]))
```

Confirmar que o valor está acima do limite de referência, que as métricas estão sendo coletadas e que o alerta voltou ao estado Normal no Grafana.

## 7. Critérios de encerramento

O incidente pode ser encerrado quando:

- O simulador estiver funcionando normalmente.
- A taxa de leituras estiver dentro do esperado.
- O Prometheus estiver coletando as métricas corretamente.
- O alerta estiver Normal no Grafana.
- A causa e as ações realizadas estiverem registradas.

## 8. Escalonamento

Se a taxa de leituras continuar baixa, registrar os resultados das consultas, os horários, os logs e os eventos. Encaminhar as evidências ao responsável pela aplicação ou pela infraestrutura Kubernetes.

**Observação:** durante períodos com pouca atividade, a taxa pode cair naturalmente. Confirmar se a queda é anormal antes de aplicar qualquer correção.
