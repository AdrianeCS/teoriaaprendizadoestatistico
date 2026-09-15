# Atividade 06 - Metodos de reamostragem (Aula 07)
# Na raiz: Rscript estrutura/codigos/06-metodos-reamostragem.R

user.lib <- file.path(Sys.getenv("USERPROFILE"), "Documents", "R", "win-library", "4.6")
dir.create(user.lib, recursive = TRUE, showWarnings = FALSE)
.libPaths(c(user.lib, .libPaths()))
if (!requireNamespace("data.table", quietly = TRUE)) {
  install.packages("data.table", lib = user.lib, repos = "https://cloud.r-project.org")
}
library(data.table)

root <- if (file.exists(file.path("estrutura", "dataset"))) {
  "."
} else if (file.exists(file.path("..", "..", "estrutura", "dataset"))) {
  file.path("..", "..")
} else {
  stop("Rode na raiz do repositorio.")
}
setwd(root)

out.dir <- file.path("consolidados", "graficos", "06")
dir.create(out.dir, recursive = TRUE, showWarnings = FALSE)

salvar <- function(nome, expr, w = 1000, h = 1000, mar = c(4.5, 4.5, 3.2, 1.2)) {
  png(file.path(out.dir, nome), width = w, height = h, res = 120)
  op <- par(pty = "s", mar = mar)
  on.exit({ par(op); dev.off() }, add = TRUE)
  force(expr)
  invisible()
}

azul <- "#2C5F8A"
laranja <- "#C45C26"
verde <- "#2E7D4F"
cinza <- "grey70"

ler <- function(f) {
  fread(f, sep = ";", dec = ",", encoding = "UTF-8",
        na.strings = c("", "n/a", "NA", "N/A"))
}

atrac  <- ler(file.path("estrutura", "dataset", "2024", "2024Atracacao.txt"))
tempos <- ler(file.path("estrutura", "dataset", "2024", "2024TemposAtracacao.txt"))
carga  <- ler(file.path("estrutura", "dataset", "2024", "2024Carga.txt"))

for (cl in c("TOperacao")) {
  if (!is.numeric(tempos[[cl]])) {
    tempos[[cl]] <- as.numeric(gsub(",", ".", as.character(tempos[[cl]]), fixed = TRUE))
  }
}
for (cl in c("VLPesoCargaBruta", "TEU")) {
  if (!is.numeric(carga[[cl]])) {
    carga[[cl]] <- as.numeric(gsub(",", ".", as.character(carga[[cl]]), fixed = TRUE))
  }
}

dt <- merge(atrac, tempos, by = "IDAtracacao")
santos <- dt[`Complexo Portuário` == "Santos" &
               `Tipo de Operação` == "Movimentação da Carga" &
               is.finite(TOperacao)]

agg <- carga[IDAtracacao %in% santos$IDAtracacao & FlagMCOperacaoCarga == 1,
             .(peso.t = sum(VLPesoCargaBruta, na.rm = TRUE),
               teu    = sum(TEU, na.rm = TRUE)),
             by = IDAtracacao]

esc <- merge(santos, agg, by = "IDAtracacao")
esc <- esc[peso.t > 0 & is.finite(TOperacao)]
esc[, y        := log1p(TOperacao)]
esc[, log.peso := log1p(peso.t)]
esc[, log.teu  := log1p(teu)]

q99 <- quantile(esc$TOperacao, 0.99)
dados <- as.data.frame(esc[TOperacao <= q99])
n <- nrow(dados)

mse <- function(m, d) mean((d$y - predict(m, d))^2)

# ---- 1) CV de 5 dobras: dois candidatos da Atividade 03/05 ----
set.seed(1)
k <- 5
dobra <- sample(rep(1:k, length = n))

cv.formula <- function(formula) {
  erro <- sapply(1:k, function(j) {
    m <- lm(formula, data = dados[dobra != j, ])
    mse(m, dados[dobra == j, ])
  })
  list(mse.dobras = erro, cv = mean(erro), rmse = sqrt(mean(erro)))
}

cv1 <- cv.formula(y ~ log.peso)
cv2 <- cv.formula(y ~ log.peso + log.teu)

vencedor <- if (cv2$cv < cv1$cv) "m2 (tonelagem + TEU)" else "m1 (so tonelagem)"

# ---- 2) bootstrap do coeficiente de log.peso no modelo multiplo ----
B <- 2000
set.seed(1)
b.peso <- replicate(B, {
  i <- sample(n, n, replace = TRUE)
  coef(lm(y ~ log.peso + log.teu, data = dados[i, ]))["log.peso"]
})

ep.peso <- sd(b.peso)
ic.peso <- quantile(b.peso, c(0.025, 0.975))
b.obs <- coef(lm(y ~ log.peso + log.teu, data = dados))["log.peso"]
dist.zero <- !(ic.peso[1] <= 0 && 0 <= ic.peso[2])

# ---- graficos ----
salvar("01-cv5-candidatos.png", {
  vals <- c(cv1$cv, cv2$cv)
  bp <- barplot(vals, names.arg = c("so tonelagem", "tonelagem + TEU"),
                col = c(azul, laranja),
                ylim = c(0, max(vals) * 1.25),
                main = "CV(5): MSE medio",
                ylab = "MSE (escala log1p(T3))")
  text(bp, vals, sprintf("%.3f", vals), pos = 3, cex = 0.9)
})

salvar("02-cv5-dobras.png", {
  mat <- rbind(cv1$mse.dobras, cv2$mse.dobras)
  bp <- barplot(mat, beside = TRUE, col = c(azul, laranja),
                names.arg = paste0("D", 1:k),
                ylim = c(0, max(mat) * 1.3),
                main = "MSE por dobra (CV 5)",
                ylab = "MSE")
  legend("topright", legend = c("so tonelagem", "tonelagem + TEU"),
         fill = c(azul, laranja), bty = "n", cex = 0.8)
})

salvar("03-bootstrap-coef-peso.png", {
  hist(b.peso, breaks = 30, col = cinza, border = "white",
       main = "Bootstrap: coef. log.peso",
       xlab = "beta (log.peso)", ylab = "frequencia")
  abline(v = ic.peso, col = laranja, lwd = 2, lty = 2)
  abline(v = b.obs, col = azul, lwd = 3)
  legend("topright",
         legend = c("estimativa", "IC 95% percentil"),
         col = c(azul, laranja), lwd = c(3, 2), lty = c(1, 2), bty = "n", cex = 0.8)
})

# estabilidade: algumas divisoes 70/30 avulsas vs CV (didatico)
set.seed(2)
graus <- 1:5
avulsa <- function(g) {
  i <- sample(n, round(0.7 * n))
  mse(lm(y ~ poly(log.peso, g), data = dados[i, ]), dados[-i, ])
}
M <- replicate(6, sapply(graus, avulsa))
cv.grau <- sapply(graus, function(g) {
  mean(sapply(1:k, function(j) {
    mse(lm(y ~ poly(log.peso, g), data = dados[dobra != j, ]),
        dados[dobra == j, ])
  }))
})

salvar("04-cv-vs-divisao-avulsa.png", {
  matplot(graus, M, type = "l", lty = 1, lwd = 1, col = cinza,
          xlab = "grau (flexibilidade)", ylab = "MSE de validacao",
          main = "Cinza: 6 divisoes 70/30 - azul: CV(5)",
          ylim = range(c(M, cv.grau)))
  lines(graus, cv.grau, col = azul, lwd = 4)
})

sink(file.path("estrutura", "codigos", "06-numeros.txt"))
cat("n=", n, "\n", sep = "")
cat("k=5 B=", B, " seed=1\n", sep = "")
cat("\n=== CV(5) m1 so tonelagem ===\n")
cat("mse.dobras=", paste(round(cv1$mse.dobras, 4), collapse = ", "), "\n", sep = "")
cat("CV=", cv1$cv, " RMSE=", cv1$rmse, "\n", sep = "")
cat("\n=== CV(5) m2 tonelagem + TEU ===\n")
cat("mse.dobras=", paste(round(cv2$mse.dobras, 4), collapse = ", "), "\n", sep = "")
cat("CV=", cv2$cv, " RMSE=", cv2$rmse, "\n", sep = "")
cat("vencedor=", vencedor, "\n", sep = "")
cat("\n=== bootstrap coef log.peso ===\n")
cat("beta.obs=", b.obs, "\n", sep = "")
cat("ep=", ep.peso, "\n", sep = "")
cat("ic.2.5=", ic.peso[1], " ic.97.5=", ic.peso[2], "\n", sep = "")
cat("distinguivel.de.zero=", dist.zero, "\n", sep = "")
sink()

cat("OK -> ", normalizePath(out.dir), "\n", sep = "")
print(list.files(out.dir))
