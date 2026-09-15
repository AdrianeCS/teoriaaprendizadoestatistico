# Atividade 05 - Avaliacao e selecao de modelos

**Team Shannon · Teoria do Aprendizado Estatistico · Fatec Rubens Lara · Aula 06**

Continua a [03a](03a-regressao-linear-t3.md): ja ajustamos dois `lm`
(so tonelagem; tonelagem + TEU). Agora a pergunta da
[Aula 06](../materiais-aulas/Aula%2006%20-%20Avaliação%20e%20Seleção%20de%20Modelos.PDF)
e outra: **qual dos dois generaliza melhor?**

Script: [`05-avaliacao-selecao-modelos.R`](../estrutura/codigos/05-avaliacao-selecao-modelos.R).
Números: [`05-numeros.txt`](../estrutura/codigos/05-numeros.txt).

---

## O funil

| # | Etapa | O que fizemos |
|---|---|---|
| 01 | Base | [Dicionario](01-dicionario-variaveis.md) |
| 02a / 02b | Analise Exploratoria | ampla e tempos T1-T4 |
| 03a / 03b | T3 em horas | reta e previsao na fila |
| 04 | T3 sim/nao | regressao logistica |
| 05 | Escolher o modelo | **esta entrega**: treino / teste + RMSE |

---

## Recorte (igual a 03a)

- Santos, 2024, movimentacao de carga
- peso > 0, T3 preenchido, T3 acima do P99 cortado
- n = 5.681 escalas

| Papel | Variavel |
|---|---|
| Y | `log1p(T3)` |
| X1 | `log1p(peso)` |
| X2 | `log1p(teu)` |

---

## Protocolo da Aula 06

Regra de ouro: o modelo **nunca ve o teste** antes da nota final.

1. Dividir 70/30 **antes** de qualquer `lm`
2. Ajustar os dois candidatos **so no treino**
3. Comparar no **teste** (RMSE)
4. Escolher um e traduzir o erro para o porto

```r
set.seed(1)
itr <- sample(nrow(dados), round(0.7 * nrow(dados)))
tr <- dados[itr, ]
te <- dados[-itr, ]

m1 <- lm(y ~ log.peso, data = tr)
m2 <- lm(y ~ log.peso + log.teu, data = tr)

mse <- function(m, d) mean((d$y - predict(m, d))^2)
sqrt(c(m1 = mse(m1, te), m2 = mse(m2, te)))
```

| Conjunto | n | Papel |
|---|---:|---|
| Treino | 3.977 (70%) | ajusta `lm` |
| Teste | 1.704 (30%) | reporta o erro (uma vez) |

`set.seed(1)` deixa a divisao reproduzivel.

---

## Dois candidatos (os mesmos da 03a)

| Modelo | Formula | Flexibilidade |
|---|---|---|
| m1 | `y ~ log.peso` | so tonelagem |
| m2 | `y ~ log.peso + log.teu` | tonelagem + TEU |

Nao usamos o teste para escolher o grau nem o limiar. Ele fica trancado
ate o passo 3.

---

## Resultado no teste

![RMSE treino x teste](graficos/05/01-rmse-treino-teste.png)

| Modelo | RMSE treino | RMSE teste | MAE teste (horas) |
|---|---:|---:|---:|
| so tonelagem (m1) | 0,676 | 0,685 | ~22,5 h |
| tonelagem + TEU (m2) | 0,552 | 0,550 | ~18,3 h |

Leitura:

- Do m1 para o m2 o erro de **teste** cai. Incluir TEU ajuda de verdade,
  nao so no treino.
- Treino e teste ficam perto um do outro. Com n grande, estes dois
  candidatos nao estao "decorando" a lista.

**Vencedor: m2 (tonelagem + TEU).**

### Frase para o porto

No teste, o modelo com peso e TEU erra o T3, em media absoluta, cerca de
**18 horas**. E melhor que o modelo so com tonelagem (~22 h), mas ainda
e uma ordem de grandeza, nao um horario fechado - a Analise Exploratoria
ja tinha mostrado cauda longa.

![Previsto x real no teste](graficos/05/02-previsto-vs-real-teste.png)

A nuvem acompanha a diagonal, com espalhamento. Confirma o MAE: da para
ordenar escalas, nao cravar minuto.

---

## Curva em U (flexibilidade so na tonelagem)

A Aula 06 mostra o U variando o grau do polinomio. Fizemos o mesmo com
`poly(log.peso, g)`, g de 1 a 6, medindo MSE no treino e no teste:

![Curva em U](graficos/05/03-curva-u-grau.png)

Com n = 5.681 o U fica quase plano nesta faixa: subir o grau so de
tonelagem muda pouco o teste. O salto grande ja veio de **adicionar o
TEU** (m1 → m2), nao de desenhar curvas em cima de um unico preditor.

---

## Vazamento: o que nao fizemos

- Nao escolhemos o vencedor olhando o teste varias vezes
- Nao cortamos o P99 nem calculamos medias usando o teste misturado
  com o treino na hora de avaliar
- A divisao veio **antes** dos `lm`

Se o numero parecer bom demais, a Aula 06 manda procurar vazamento.

---

## Conclusao

1. Protocolo: treino ajusta, teste reporta (uma vez).
2. Entre m1 e m2, vence **tonelagem + TEU** (RMSE teste 0,55; MAE ~18 h).
3. RMSE/MAE falam a lingua do problema (horas de operacao em Santos).
4. Proximo passo ([06](06-metodos-reamostragem.md)): quando uma divisao
   so for loteria, entra validacao cruzada e bootstrap.

---

## Como reproduzir

```r
Rscript estrutura/codigos/05-avaliacao-selecao-modelos.R
```

*Fonte: ANTAQ, Santos 2024.*
