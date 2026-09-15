# Atividade 05 - Avaliação e seleção de modelos

**Team Shannon · Teoria do Aprendizado Estatístico · Fatec Rubens Lara · Aula 06**

Continua a [03a](03a-regressao-linear-t3.md): já ajustamos dois `lm`
(só tonelagem; tonelagem + TEU). Agora a pergunta da
[Aula 06](../materiais-aulas/Aula%2006%20-%20Avaliação%20e%20Seleção%20de%20Modelos.PDF)
é outra: **qual dos dois generaliza melhor?**

Script: [`05-avaliacao-selecao-modelos.R`](../estrutura/codigos/05-avaliacao-selecao-modelos.R).
Números: [`05-numeros.txt`](../estrutura/codigos/05-numeros.txt).
Pacote: base (`lm`, `predict`, `poly`, `sample`); `data.table` só na leitura.

---

## O funil

| # | Etapa | O que fizemos |
|---|---|---|
| 01 | Base | [Dicionário](01-dicionario-variaveis.md) |
| 02a / 02b | Análise Exploratória | ampla e tempos T1-T4 |
| 03a / 03b | T3 em horas | reta e previsão na fila |
| 04 | T3 sim/não | regressão logística |
| 05 | Escolher o modelo | **esta entrega**: treino / teste + RMSE |

---

## 1. Por que ajustar não basta

Na Aula 04 aprendemos a ajustar (`lm`). Na Aula 05, `glm`. Isso responde
*como a curva passa pelos dados que já temos*. A Aula 06 pergunta:
*esse ajuste serve amanhã, em casos novos?*

O fio da aula é uma imobiliária prevendo `preco` (mil R$) a partir de
`area` (m²), com n = 120 imóveis e três candidatos:

| Grau | Ideia |
|---:|---|
| 1 | reta - talvez simples demais |
| 3 | curva suave |
| 12 | persegue quase cada ponto |

Os três “explicam” os 120 pontos. Qual entregar para usar amanhã?
Só o erro **fora da amostra** responde.

No nosso banco a pergunta é a mesma, trocando imóvel por escala:

| Aula (imobiliária) | Nossa entrega (Santos) |
|---|---|
| `preco ~ area` | `log1p(T3) ~ log1p(peso)` (+ TEU) |
| graus 1, 3, 12 | m1 (só peso) vs m2 (peso + TEU) |
| RMSE em mil R$ | RMSE em escala log; MAE em **horas** |

---

## 2. Recorte dos dados (Santos)

- Santos, 2024, movimentação de carga
- peso > 0, T3 preenchido, T3 acima do P99 cortado
- n = 5.681 escalas

| Papel | Variável |
|---|---|
| Y | `log1p(T3)` |
| X1 | `log1p(peso)` |
| X2 | `log1p(teu)` |

T1, T2, T4, TA e TE não entram como preditores (mesmo relógio da escala).

---

## 3. Regressão polinomial (ideia da aula)

A aula mostra que “linear” é nos β. O grau só fabrica colunas:

**Grau 1:** \(\hat{y} = \hat{\beta}_0 + \hat{\beta}_1 x\)

**Grau 3:** \(\hat{y} = \hat{\beta}_0 + \hat{\beta}_1 x + \hat{\beta}_2 x^2 + \hat{\beta}_3 x^3\)

**Grau 12:** até \(x^{12}\).

Em matriz: \(\mathbf{y} = X\boldsymbol{\beta} + \boldsymbol{\varepsilon}\).
Para g = 2, cada linha de X é \([1,\ x_i,\ x_i^2]\). O estimador continua
o de mínimos quadrados da Aula 04.

Três jeitos no R (mesmo ajuste, coeficientes diferentes):

```r
m1 <- lm(preco ~ area + I(area^2) + I(area^3))
m2 <- lm(preco ~ poly(area, 3, raw = TRUE))
m3 <- lm(preco ~ poly(area, 3))   # ortogonal (padrão)
```

`I()` protege o `^`. `poly` padrão (ortogonal) é preferível em grau alto:
mesmas previsões, contas mais estáveis. Não interpretar cada β isolado e
não extrapolar fora da faixa de x - a curva de grau 12 “mergulha” nas bordas.

No laboratório usamos `poly(log.peso, g)` só para desenhar a **curva em U**
(seção 8). A escolha principal do porto fica entre m1 e m2 (seção 7).

---

## 4. Erro de treino × erro de teste

| Conceito | Onde mede | Analogia da aula |
|---|---|---|
| Erro de **treino** | nos mesmos dados do ajuste | refazer a lista com gabarito |
| Erro de **teste** | em dados que o modelo **nunca viu** | prova inédita |

Só o de teste mede generalização. Quem decora a lista tira 10 nela e vai
mal na prova: **sobreajuste**.

Referência da aula (120 imóveis, 70/30):

| Grau | MSE treino | MSE teste |
|---:|---:|---:|
| 1 | 942 | 910 |
| 3 | 861 | 841 |
| 12 | 758 | 995 |

Treino só cai; teste cai e depois sobe. O grau 12 decorou a lista.

---

## 5. Protocolos de divisão

### Treino / teste (≈ 70/30)

- **Treino:** onde roda o `lm`
- **Teste:** trancado até o fim; usado **uma vez**

Regra de ouro: o modelo nunca vê o teste antes da nota final.

### Treino / validação / teste (quando há escolha)

Com muitos candidatos (ex.: 12 graus), entra um conjunto do meio:

| Conjunto | Papel | Analogia |
|---|---|---|
| Treino | ajusta cada candidato | estudar a lista |
| Validação | compara e **escolhe** | simulado |
| Teste | reporta só o escolhido | prova final |

Exemplo da aula com 300 casos: 180 / 60 / 60.

**Erro comum:** usar o teste para escolher o grau. Isso transforma o teste
em validação e a “nota final” fica boa demais.

---

## 6. Viés, variância e a curva em U

- **Viés (grau 1):** modelo rígido demais; erra sempre do mesmo jeito.
- **Variância (grau 12):** muda se trocar meia dúzia de pontos; segue o ruído.

Decomposição do erro esperado em um ponto \(x_0\):

\[
\mathrm{E}\bigl[(y_0 - \hat{f}(x_0))^2\bigr]
=
\mathrm{Var}(\hat{f})
+
\bigl[\mathrm{Bias}(\hat{f})\bigr]^2
+
\mathrm{Var}(\varepsilon)
\]

### Conta da aula

Var = 0,04; Bias = 0,3; Var(ε) = 0,02:

\[
0{,}04 + (0{,}3)^2 + 0{,}02 = 0{,}04 + 0{,}09 + 0{,}02 = 0{,}15
\]

Domina o **viés** (0,09) → vale aumentar a flexibilidade.

### Exercício resolvido (viés-variância)

Var = 0,05; Bias = 0,2; Var(ε) = 0,03:

\[
0{,}05 + (0{,}2)^2 + 0{,}03 = 0{,}05 + 0{,}04 + 0{,}03 = 0{,}12
\]

Domina a **variância** (0,05) → vale **diminuir** a flexibilidade.

A curva em U: treino só desce; teste desce e sobe. O melhor mora no fundo.

---

## 7. Laboratório: dois candidatos no nosso banco

### Divisão 70/30 antes de qualquer ajuste

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

| Modelo | Fórmula | Flexibilidade |
|---|---|---|
| m1 | `y ~ log.peso` | só tonelagem |
| m2 | `y ~ log.peso + log.teu` | tonelagem + TEU |

### Resultado no teste

![RMSE treino x teste](graficos/05/01-rmse-treino-teste.png)

| Modelo | RMSE treino | RMSE teste | MAE teste (horas) |
|---|---:|---:|---:|
| só tonelagem (m1) | 0,676 | 0,685 | ~22,5 h |
| tonelagem + TEU (m2) | 0,552 | **0,550** | **~18,3 h** |

Leitura:

- Do m1 para o m2 o erro de **teste** cai. Incluir TEU ajuda de verdade,
  não só no treino.
- Treino e teste ficam perto. Com n = 5.681 estes dois candidatos não
  estão decorando a lista (diferente do grau 12 da aula com n = 120).

**Vencedor: m2 (tonelagem + TEU).**

### Frase para o porto

No teste, o modelo com peso e TEU erra o T3, em média absoluta, cerca de
**18 horas**. É melhor que só tonelagem (~22 h), mas ainda é ordem de
grandeza, não horário fechado - a Análise Exploratória já tinha mostrado
cauda longa.

![Previsto x real no teste](graficos/05/02-previsto-vs-real-teste.png)

A nuvem acompanha a diagonal, com espalhamento. Confirma o MAE: dá para
ordenar escalas, não cravar minuto.

---

## 8. Curva em U no nosso banco

A aula varia o grau do polinômio. Fizemos o mesmo com
`poly(log.peso, g)`, g de 1 a 6, MSE no treino e no teste:

![Curva em U](graficos/05/03-curva-u-grau.png)

| Grau | MSE teste |
|---:|---:|
| 1 | 0,470 |
| 2 | 0,468 |
| 3 | 0,459 |
| 4 | 0,457 |
| 5 | 0,458 |
| 6 | 0,457 |

Com n grande o U fica quase plano nesta faixa: subir o grau **só** de
tonelagem muda pouco. O salto grande já veio de **adicionar o TEU**
(m1 → m2), não de desenhar curvas em cima de um único preditor.

---

## 9. Métricas: MSE, RMSE e MAE

| Métrica | Fórmula / leitura |
|---|---|
| MSE | média dos erros ao quadrado |
| RMSE | \(\sqrt{\mathrm{MSE}}\) - erro típico na unidade de Y |
| MAE | média dos \|erros\| - mais robusto a outliers |

Na aula (preço em mil R$): MSE teste ≈ 900 ⇒ RMSE = \(\sqrt{900} = 30\)
(erro típico de 30 mil reais).

### Exercício resolvido (aula): MSE = 2.500

\[
\mathrm{RMSE} = \sqrt{2500} = 50
\]

Frase para a imobiliária: “Em imóveis novos, o erro típico fica em torno
de **50 mil reais** no preço previsto.”

### Exercício resolvido: y = (10, 12, 15), ŷ = (11, 11, 16)

Erros: \(1\), \(-1\), \(1\).

\[
\mathrm{MSE} = \frac{1^2 + (-1)^2 + 1^2}{3} = \frac{3}{3} = 1
\quad;\quad
\mathrm{RMSE} = \sqrt{1} = 1
\]

No nosso laboratório reportamos RMSE na escala `log1p(T3)` (comparação
justa dos `lm`) e MAE em **horas** (língua do porto).

---

## 10. Seleção e vazamento

Procedimento completo da aula:

1. Ajustar cada candidato no **treino**
2. Comparar na **validação** e escolher
3. Reportar o escolhido no **teste** (uma vez)

### Exemplo da aula (validação)

| Grau | MSE validação |
|---:|---:|
| 1 | 2.900 |
| 3 | **1.050** |
| 12 | 2.300 |

Escolhe-se o **grau 3**. Só então mede-se o teste (ex.: 980) - esse é o
número reportado. No nosso lab, com **dois** candidatos, a própria métrica
de teste (uma vez, seed fixa) faz o papel de comparação, como pede o
laboratório da Aula 06.

### Vazamento (data leakage)

Informação do teste (ou do futuro) escorrendo para o ajuste ou a escolha.

Três flagrantes clássicos:

1. Usar o teste para escolher grau / limiar
2. Normalizar ou imputar com a **base inteira** antes de dividir
3. Duplicatas / mesma escala no treino e no teste

### Caça ao vazamento (resolvido)

Colega imputa faltantes com a média da base **inteira** e depois divide
treino/teste.

- **Onde está o vazamento?** A média “viu” valores que depois caem no teste.
- **Como corrigir?** Dividir primeiro; calcular a média **só no treino**;
  imputar treino e teste com essa média do treino.

### O que não fizemos nesta entrega

- Não escolhemos o vencedor olhando o teste várias vezes
- Não misturamos teste no cálculo do P99 na hora de avaliar
- A divisão 70/30 veio **antes** dos `lm` (`set.seed(1)`)

---

## 11. Exercícios conceituais (resolvidos)

**Por que o erro de treino é quase sempre menor que o de teste?**  
O ajuste foi feito para reduzir o erro nos pontos de treino. O teste traz
padrões e ruído novos. Com mais flexibilidade a diferença cresce: o modelo
cola no treino (sobreajuste).

**Por que escolher o modelo pelo teste deixa a nota “boa demais”?**  
O teste gasta-se na escolha e deixa de ser prova final. Quem deveria
escolher é a **validação**; o teste só reporta o vencedor uma vez.

---

## 12. Conclusão

1. Erro de teste mede generalização; erro de treino lisonjeia.
2. Protocolo: treino ajusta; (validação escolhe); teste reporta uma vez.
3. Viés-variância: flexibilidade troca um pelo outro; o teste faz um U.
4. No Santos, entre m1 e m2 vence **tonelagem + TEU** (RMSE teste 0,55;
   MAE ~18 h).
5. Métrica na língua do problema; cuidado com vazamento.
6. Próximo passo ([06](06-metodos-reamostragem.md)): quando uma divisão só
   for loteria, entra CV e bootstrap.

---

## Como reproduzir

```r
Rscript estrutura/codigos/05-avaliacao-selecao-modelos.R
```

Gráficos em `consolidados/graficos/05/`:

| Arquivo | Conteúdo |
|---|---|
| `01-rmse-treino-teste.png` | RMSE treino × teste (m1 vs m2) |
| `02-previsto-vs-real-teste.png` | nuvem no teste (modelo vencedor) |
| `03-curva-u-grau.png` | MSE × grau de `poly(log.peso)` |

*Fonte: ANTAQ, Santos 2024. Teoria: Aula 06 (Prof. Dr. João Paulo Ferreira de Mello).*
