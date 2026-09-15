# Atividade 05 - Avaliacao e selecao de modelos (Aula 06)
# Na raiz: Rscript estrutura/codigos/05-avaliacao-selecao-modelos.R

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

out.dir <- file.path("consolidados", "graficos", "05")
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
esc[, T3       := TOperacao]

q99 <- quantile(esc$T3, 0.99)
esc.m <- esc[T3 <= q99]

# ---- 1) dividir 70/30 ANTES de qualquer ajuste ----
set.seed(1)
n <- nrow(esc.m)
itr <- sample(n, round(0.7 * n))
tr <- esc.m[itr]
te <- esc.m[-itr]

# ---- 2) ajustar DOIS candidatos so no treino ----
m1 <- lm(y ~ log.peso, data = tr)
m2 <- lm(y ~ log.peso + log.teu, data = tr)

mse <- function(m, d) mean((d$y - predict(m, d))^2)
rmse <- function(m, d) sqrt(mse(m, d))
mae.h <- function(m, d) {
  pred <- expm1(predict(m, d))
  mean(abs(d$T3 - pred))
}

mse.tr <- c(m1 = mse(m1, tr), m2 = mse(m2, tr))
mse.te <- c(m1 = mse(m1, te), m2 = mse(m2, te))
rmse.tr <- sqrt(mse.tr)
rmse.te <- sqrt(mse.te)
mae.te <- c(m1 = mae.h(m1, te), m2 = mae.h(m2, te))

vencedor <- names(which.min(rmse.te))

# ---- graficos ----
salvar("01-rmse-treino-teste.png", {
  mat <- rbind(rmse.tr, rmse.te)
  colnames(mat) <- c("so tonelagem", "tonelagem + TEU")
  bp <- barplot(mat, beside = TRUE, col = c(verde, laranja),
                ylim = c(0, max(mat) * 1.25),
                main = "RMSE: treino x teste",
                ylab = "RMSE (escala log1p(T3))")
  legend("topright", legend = c("treino", "teste"),
         fill = c(verde, laranja), bty = "n")
  text(bp, mat, sprintf("%.3f", mat), pos = 3, cex = 0.8)
})

salvar("02-previsto-vs-real-teste.png", {
  set.seed(1)
  pred2 <- expm1(predict(m2, te))
  idx <- sample.int(nrow(te), min(2500L, nrow(te)))
  plot(pred2[idx], te$T3[idx],
       pch = 16, cex = 0.35, col = rgb(44/255, 95/255, 138/255, 0.3),
       main = "Teste: T3 previsto x real (modelo 2)",
       xlab = "T3 previsto (h)", ylab = "T3 real (h)")
  abline(0, 1, col = laranja, lwd = 2)
})

# curva em U com grau de poly(log.peso) - didatico Aula 06
graus <- 1:6
etr <- ete <- numeric(length(graus))
for (i in seq_along(graus)) {
  g <- graus[i]
  m <- lm(y ~ poly(log.peso, g), data = tr)
  etr[i] <- mse(m, tr)
  ete[i] <- mse(m, te)
}
g.best <- graus[which.min(ete)]

salvar("03-curva-u-grau.png", {
  matplot(graus, cbind(etr, ete), type = "l", lwd = 3, lty = 1,
          col = c(verde, laranja),
          xlab = "grau (flexibilidade)", ylab = "MSE",
          main = "Curva em U: poly(log.peso)")
  legend("topright", legend = c("treino", "teste"),
         col = c(verde, laranja), lwd = 3, bty = "n")
  points(g.best, min(ete), pch = 19, cex = 1.4, col = azul)
})

sink(file.path("estrutura", "codigos", "05-numeros.txt"))
cat("n=", n, "\n", sep = "")
cat("n.treino=", nrow(tr), " n.teste=", nrow(te), "\n", sep = "")
cat("seed=1 prop.treino=0.7\n", sep = "")
cat("\n=== RMSE treino (log1p) ===\n")
print(rmse.tr)
cat("\n=== RMSE teste (log1p) ===\n")
print(rmse.te)
cat("\n=== MAE teste (horas) ===\n")
print(mae.te)
cat("\nvencedor=", vencedor, "\n", sep = "")
cat("\n=== coef m2 (treino) ===\n")
print(coef(m2))
cat("\n=== curva U: MSE teste por grau ===\n")
print(setNames(ete, paste0("grau", graus)))
cat("grau.melhor.u=", g.best, "\n", sep = "")
sink()

cat("OK -> ", normalizePath(out.dir), "\n", sep = "")
print(list.files(out.dir))
