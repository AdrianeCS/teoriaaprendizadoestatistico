# Teoria do Aprendizado Estatístico - Team Shanno

**Ciência de Dados · Fatec Rubens Lara - Baixada Santista**

Estimar e avaliar modelos de aprendizado a partir de dados - da regressão
às redes neurais e ao aprendizado não supervisionado - com
**pseudocódigo** e implementação em **R**.

![R](https://img.shields.io/badge/R-base-276DC3?style=flat&logo=r&logoColor=white)
![Status](https://img.shields.io/badge/status-em%20andamento-yellow)
![Equipe](https://img.shields.io/badge/equipe-Team%20Shannon-0B3954)
![Banco](https://img.shields.io/badge/banco-ANTAQ%20local-lightgrey)

---

## Sobre a disciplina

**Objetivo:**  
Utilizar conhecimentos estatísticos para análise e projeto de algoritmos de aprendizado de máquina para modelar, compreender e analisar conjuntos de dados complexos. Escrever esses algoritmos em pseudocódigo e executá-los por meio de linguagens de programação. Utilizar os conhecimentos adquiridos em problemas de Ciência de Dados para fundamentar a tomada de decisões baseadas em informações obtidas por meio de algoritmos de aprendizado de máquina.

**Ementa:**  
Teoria da aprendizagem estatística. Métodos de reamostragem. Expansão e regularização. Métodos de suavização. Método EM (Expectation-Maximization). Avaliação e seleção de modelos. Árvores de decisão. Redes neurais e aprendizado de máquina (redes Adaline, Madaline, Perceptron e Multilayer Perceptron - MLP). Máquina de vetores suporte. Agrupamentos. Componentes principais e independentes. Aplicação desses conhecimentos para solução dos problemas de Ciência de Dados, utilizando linguagem de programação.

**Professor:**  
Prof. Dr. João Paulo Ferreira de Mello  
([joao.mello12@fatec.sp.gov.br](mailto:joao.mello12@fatec.sp.gov.br))

**Equipe:** Team Shannon  

**Alunos:**  
Adriane da Costa Santos  
([adriane.santos01@aluno.cps.sp.gov.br](mailto:adriane.santos01@aluno.cps.sp.gov.br))

Danilo Prado de Lima Silva  
([danilo.silva25@aluno.cps.sp.gov.br](mailto:danilo.silva25@aluno.cps.sp.gov.br))

Victória Cabral Quintério  
([victoria.quinterio@aluno.cps.sp.gov.br](mailto:victoria.quinterio@aluno.cps.sp.gov.br))

**Linguagem das entregas:**  
Sempre **R base**.

**Banco de trabalho:**  
O Dataset de Dados Estatístico Aquaviário (ANTAQ), recorte 2021-2025, está em `estrutura/dataset` (~4,6 GB). Fica só na máquina local e no Google Drive; pelo tamanho não entra no GitHub.

---

## Cinco blocos do curso

| Bloco | Conteúdo                                          |
| ----- | ------------------------------------------------- |
| I     | Fundamentos do aprendizado estatístico            |
| II    | Supervisionado: avaliação e regularização         |
| III   | Modelos flexíveis: suavização, árvores, ensembles |
| IV    | Redes neurais e SVM                               |
| V     | Não supervisionado: agrupamento, EM, PCA/ICA      |

As Aulas 01-05 abrem o **Bloco I** e o início do supervisionado:
estimar \(f\), tipar dados, explorar, regressão linear e regressão logística.

---

## Estrutura do repositório

Mesmo padrão do Projeto Integrador III (mesmo professor).

```
.
├── README.md
├── estrutura/
│   ├── dataset/                  # ANTAQ local - fora do Git
│   └── codigos/                  # todos os scripts .R
│       ├── 01-dicionario-variaveis.R
│       ├── 02a-analise-exploratoria-ampla.R
│       ├── 02b-analise-exploratoria-segmentada.R
│       ├── 03a-regressao-linear-t3.R
│       ├── 03b-previsao-fila-t3.R
│       ├── 04-regressao-logistica.R
│       ├── 05-avaliacao-selecao-modelos.R
│       └── 06-metodos-reamostragem.R
├── consolidados/                 # todas as entregas .md
│   ├── 01-dicionario-variaveis.md
│   ├── 02a-analise-exploratoria-ampla.md
│   ├── 02b-analise-exploratoria-segmentada.md
│   ├── 03a-regressao-linear-t3.md
│   ├── 03b-previsao-fila-t3.md
│   ├── 04-regressao-logistica.md
│   ├── 05-avaliacao-selecao-modelos.md
│   ├── 06-metodos-reamostragem.md
│   └── graficos/
├── materiais-aulas/              # PDFs das aulas
└── to-delete-trash/              # pasta antiga Atividades/ (lixo)
```

| Pasta | Conteúdo |
|---|---|
| `estrutura/dataset` | Microdados ANTAQ (local, fora do Git) |
| `estrutura/codigos` | Códigos R das entregas |
| `consolidados` | Relatórios/entregas em Markdown |
| `materiais-aulas` | Slides/PDFs |
| `to-delete-trash` | Layout antigo - pode apagar depois de conferir |

---

## Atividades × aulas

| # | Entrega | Script | Aula |
|---|---|---|---|
| 01 | [01-dicionario-variaveis.md](consolidados/01-dicionario-variaveis.md) | `01-dicionario-variaveis.R` | Aula 02 |
| 02a | [02a-analise-exploratoria-ampla.md](consolidados/02a-analise-exploratoria-ampla.md) | `02a-analise-exploratoria-ampla.R` | Aula 03 |
| 02b | [02b-analise-exploratoria-segmentada.md](consolidados/02b-analise-exploratoria-segmentada.md) | `02b-analise-exploratoria-segmentada.R` | Aula 03 |
| 03a | [03a-regressao-linear-t3.md](consolidados/03a-regressao-linear-t3.md) | `03a-regressao-linear-t3.R` | Aula 04 |
| 03b | [03b-previsao-fila-t3.md](consolidados/03b-previsao-fila-t3.md) | `03b-previsao-fila-t3.R` | Aula 04 |
| 04 | [04-regressao-logistica.md](consolidados/04-regressao-logistica.md) | `04-regressao-logistica.R` | Aula 05 |
| 05 | [05-avaliacao-selecao-modelos.md](consolidados/05-avaliacao-selecao-modelos.md) | `05-avaliacao-selecao-modelos.R` | Aula 06 |
| 06 | [06-metodos-reamostragem.md](consolidados/06-metodos-reamostragem.md) | `06-metodos-reamostragem.R` | Aula 07 |

Funil: dicionário → Análise Exploratória → T3 (horas) → T3 (sim/não) → escolha por teste → CV e bootstrap.

---

## Como rodar os códigos

Na raiz do repositório, com `estrutura/dataset` disponível:

```bash
Rscript estrutura/codigos/01-dicionario-variaveis.R
Rscript estrutura/codigos/02a-analise-exploratoria-ampla.R
Rscript estrutura/codigos/02b-analise-exploratoria-segmentada.R
Rscript estrutura/codigos/03a-regressao-linear-t3.R
Rscript estrutura/codigos/03b-previsao-fila-t3.R
Rscript estrutura/codigos/04-regressao-logistica.R
Rscript estrutura/codigos/05-avaliacao-selecao-modelos.R
Rscript estrutura/codigos/06-metodos-reamostragem.R
```

Os scripts leem `estrutura/dataset` e gravam PNGs em `consolidados/graficos/`.
O nome casa em tudo: `05-avaliacao-selecao-modelos.R`, `05-avaliacao-selecao-modelos.md` e `05-numeros.txt` (o mesmo vale para 01-06).
