# Evidências — OAT 2

| Arquivo | O que comprova |
| --- | --- |
| prometheus-targets.png | Target `iot-simulator` com estado UP (coleta funcionando) |
| dashboard-cpu.png | Dashboard de CPU no Grafana |
| dashboard-memoria.png | Dashboard de memória no Grafana |
| dashboard-erros.png | Dashboard de taxa de erros |
| dashboard-sucessos.png | Dashboard de leituras com sucesso (salto durante a carga) |
| grafana-4-alarmes.png | As 4 regras de alerta ativas (Taxa de Erros em Firing) |
| alarme-cpu.png | Regra CPU Alta (limite 80) |
| alarme-memoria.png | Regra Memória Alta (limite 107374182 bytes = 80% de 128Mi) |
| alarme-taxa-erros.png | Regra Taxa de Erros Alta (limite 5) |
| alarme-taxa-erros-historico.png | Histórico do alarme: Pending → Alerting → Normal |
| hpa-escala-5-replicas.png | HPA com CPU 114%/60% e 5 réplicas durante o teste de estresse |
| hpa-volta-1-replica.png | HPA reduzindo de 2 para 1 réplica após a carga normalizar |
| hpa-describe.png | `kubectl describe hpa` com métricas e condições |
| pods-e-hpa.png | Pods em Running nos namespaces mecaniqa e monitoring |
