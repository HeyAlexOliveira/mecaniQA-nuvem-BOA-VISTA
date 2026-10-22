# Runbook — Memória Alta

**Projeto:** MecaniQA Tech  
**Encontro:** 4 — Monitorando a Continuidade  
**Alerta:** MecaniQA - Memória Alta  
**Objetivo:** Diagnosticar e tratar o consumo elevado de memória do simulador IoT no Kubernetes.

## 1. Quando utilizar

Utilizar este procedimento quando o alerta de memória alta estiver ativo no Grafana ou quando o consumo de memória estiver próximo do limite configurado.

## 2. Verificações iniciais

Verificar os pods do sistema:

```powershell
kubectl get pods -n mecaniqa
```

Consultar o consumo atual de memória:

```powershell
kubectl top pods -n mecaniqa
```

Verificar o estado do deployment:

```powershell
kubectl get deployment iot-simulator -n mecaniqa
```

Consultar os detalhes do deployment:

```powershell
kubectl describe deployment iot-simulator -n mecaniqa
```

## 3. Diagnóstico

Consultar os logs recentes:

```powershell
kubectl logs deployment/iot-simulator -n mecaniqa --tail=100
```

Verificar eventos do namespace:

```powershell
kubectl get events -n mecaniqa --sort-by=.lastTimestamp
```

Verificar se ocorreram reinicializações ou encerramentos por falta de memória:

```powershell
kubectl describe pods -n mecaniqa
```

Nos detalhes dos pods, procurar estados como `OOMKilled`, reinicializações e mensagens relacionadas a limites de memória.

## 4. Possíveis causas

- Consumo crescente de memória pelo processo.
- Limite de memória insuficiente para a carga atual.
- Aumento da quantidade de leituras ou do volume de processamento.
- Reinicializações causadas por falta de memória.

## 5. Ações corretivas

1. Confirmar se o consumo elevado é persistente.
2. Analisar logs, eventos e reinicializações dos pods.
3. Verificar as solicitações e os limites de memória configurados.
4. Se necessário, solicitar autorização para revisar os recursos do deployment.
5. Não aumentar limites nem reiniciar pods sem avaliar a causa e o impacto da alteração.

## 6. Validação da recuperação

Consultar novamente o consumo:

```powershell
kubectl top pods -n mecaniqa
```

Verificar o estado dos pods:

```powershell
kubectl get pods -n mecaniqa
```

Confirmar se o consumo está abaixo do limite configurado e se o alerta voltou ao estado Normal no Grafana.

## 7. Critérios de encerramento

O incidente pode ser encerrado quando:

- O consumo de memória estiver estabilizado.
- Os pods estiverem funcionando normalmente.
- Não houver novos encerramentos por falta de memória.
- O alerta estiver Normal no Grafana.
- A causa e as ações realizadas estiverem registradas.

## 8. Escalonamento

Se o consumo continuar elevado ou ocorrerem encerramentos por falta de memória, registrar os resultados dos comandos, os horários, os logs e os eventos. Encaminhar as evidências ao responsável pela infraestrutura Kubernetes.

**Observação:** a regra do Grafana deve ser conferida para confirmar a consulta e o limite exatos utilizados no alerta.
