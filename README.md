# mecaniQA-boa-vista

## Contexto

Este repositório contém a entrega do **Entregável 1** do time **Boa Vista** para o desafio **MecâniQA**.

A MecâniQA — rede de oficinas e auto centers de Feira de Santana e região — enfrenta picos inesperados de demanda de manutenção preventiva em determinados veículos, gerando falta de peças em estoque em alguns dias e ociosidade da equipe de mecânicos em outros.

Neste primeiro desafio, atuamos como o time de Ciência de Dados da MecâniQA. Nossa missão foi desenvolver o **módulo fundacional de análise** do sistema preditivo: modelar e limpar os dados temporais fundamentais do negócio (Trocas de Óleo e Manutenções de Motor) e criar o primeiro motor de previsão **"ingênuo" (Baseline)**, que servirá como piso de comparação para os futuros modelos de Machine Learning.

## Objetivos da sprint

- Compreender a estrutura de dados temporais e indexação por tempo.
- Executar Análise Exploratória de Dados (EDA) para séries temporais, identificando Tendência, Sazonalidade e Ruído.
- Tratar dados ausentes, valores inválidos e outliers.
- Implementar e documentar os modelos Baseline (Naive e Médias Móveis).

## Conteúdo do repositório

- `mecaniQA_boa-vista.ipynb` — notebook executado, com análise, limpeza de dados, decomposição e modelos baseline (Naive e Médias Móveis 7/30 dias).
- `mecaniqa_dataset.xlsx` — dataset com o histórico de manutenções.
- `mecaniQA_oat1_boa-vista.pdf` — apresentação da entrega, em PDF, conforme o padrão exigido.

## Time: Boa Vista

| Membro   | Nome                        |
| -------- | --------------------------- |
| Membro 1 | Alex Oliveira Santos        |
| Membro 2 | Alice Gomes Aragão          |
| Membro 3 | Ana Clara Ribeiro da Silva  |
| Membro 4 | Lorran Edley Matos Ribeiro  |
| Membro 5 | Rodrigo dos Anjos Lamartine |

## Principais tratamentos realizados

- Verificação da integridade da linha do tempo antes de completar a frequência diária.
- Interpolação temporal dos valores ausentes.
- Identificação de **5 valores negativos inválidos** em Manutenção de Motor, tratados como `NaN` e interpolados.
- Detecção de outliers pelo método IQR e clipping dos valores extremos, preservando a continuidade da série.
- Avaliação dos baselines nos últimos 30 dias por MAE e RMSE.
