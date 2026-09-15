# Atividade 03a - Regressão linear de T3

**Team Shannon · Teoria do Aprendizado Estatístico · Fatec Rubens Lara · Aula 04**

Continua a Análise Exploratória segmentada em Santos:
[02b](02b-analise-exploratoria-segmentada.md).

Pergunta: dá para estimar T3 olhando a tonelagem e o TEU da escala?

Script: [`03a-regressao-linear-t3.R`](../estrutura/codigos/03a-regressao-linear-t3.R).
Números: [`03a-numeros.txt`](../estrutura/codigos/03a-numeros.txt).
Pacote da aula: base (`lm`, `summary`, `plot`, `predict`, `cor`);
`data.table` só na leitura.

A mesma reta é reaplicada na fila em
[03b](03b-previsao-fila-t3.md).

---

## Recorte

- Santos, 2024, movimentação de carga
- T3 preenchido, peso da escala > 0
- T3 acima do P99 cortado
- n = 5.681 escalas

| Papel | Variável |
|---|---|
| Y | `log1p(T3)` |
| X1 | `log1p(peso)` |
| X2 | `log1p(teu)` |

T1, T2, T4, TA e TE não entram como preditores. Fazem parte do mesmo
relógio da escala.

---

## Modelo simples (só tonelagem)

```r
m.simples <- lm(log1p(T3) ~ log1p(peso), data = esc.m)
```

\[
\widehat{\log(1+\mathrm{T3})} \approx -0{,}06 + 0{,}36 \cdot \log(1+\mathrm{peso})
\]

- R² cerca de 0,26
- Mais toneladas tendem a dar mais tempo de operação.

![Reta simples](graficos/03a/01-reta-simples.png)

## Tonelagem e TEU se repetem?

| | log(peso) | log(TEU) |
|---|---:|---:|
| log(peso) | 1,00 | 0,01 |
| log(TEU) | 0,01 | 1,00 |

![Correlação peso x TEU](graficos/03a/02-cor-peso-teu.png)

r cerca de 0,01. Quase independentes, dá para colocar os dois juntos.

## Modelo múltiplo

```r
m.multi <- lm(log1p(T3) ~ log1p(peso) + log1p(teu), data = esc.m)
```

\[
\widehat{\log(1+\mathrm{T3})} \approx 0{,}22 + 0{,}36\,\log(1+\mathrm{peso}) - 0{,}11\,\log(1+\mathrm{TEU})
\]

| Preditor | Coef. | Leitura |
|---|---:|---|
| Tonelagem | +0,36 | mais peso, mais T3 |
| TEU | -0,11 | com o mesmo peso, mais contêiner puxa T3 um pouco para baixo |

| Modelo | R² |
|---|---:|
| Só tonelagem | 0,26 |
| Tonelagem + TEU | 0,51 |

Incluir TEU ajuda bastante, mas metade da variação ainda fica de fora. A
Análise Exploratória (02b) já tinha mostrado cauda longa.

![Resíduos vs ajustados](graficos/03a/03-residuos-vs-ajustados.png)

Os resíduos ficam em torno de zero, sem padrão forte, mas espalhados. Serve
como primeiro modelo, não como horário fechado.

## Previsão escrita

Marco um x0 (peso), subo na reta, leio y chapéu e volto para horas com `expm1()`.

![Previsão em x0](graficos/03a/04-previsao-x0.png)

| Cenário | Peso | TEU | T3 previsto |
|---|---:|---:|---:|
| Mediano, sem contêiner | ~24.283 t | 0 | ~47 h |
| Leve com contêiner (P25) | ~11.362 t | moderado | ~14 h |
| Pesado (P90) | ~66.396 t | alto | ~28 h |

Com peso e TEU dá para ter uma ordem de grandeza do T3. O intervalo continua
largo porque a distribuição é assimétrica.

---

## Conclusão

1. T3 se explica em parte com tonelagem e TEU (R² de 0,26 para 0,51).
2. Três cenários escritos mostram como usar a reta na prática.
3. A reta segue para a previsão na fila em [03b](03b-previsao-fila-t3.md).

---

## Como reproduzir

```r
Rscript estrutura/codigos/03a-regressao-linear-t3.R
```

*Fonte: ANTAQ, Santos 2024.*
