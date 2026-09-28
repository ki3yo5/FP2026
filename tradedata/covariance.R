# 競合防止のためlibrary(tidyr)の前にlibrary(MASS)
library(MASS)
library(readr)
library(dplyr)
library(stringr)
library(tidyr)
library(purrr)
library(broom)
library(ggplot2)
library(tseries)


# 対数差分、トレンド除去、ADF検定、共分散行列----

# 1. データ読込----

food <- read_csv("world_export_grouped.csv", show_col_types = FALSE)
fert <- read_csv("fertilizer_exports_merged_all.csv", show_col_types = FALSE)


# 2. 列名と構造を統----
#   食料: Year, item_group, Value
#   肥料: refYear, fertilizer, qty_merged_ton

food_long <- food %>%
  transmute(
    Year = as.integer(Year),
    item = as.character(item_group),
    quantity = as.numeric(Value),
    category = "food"
  )

fert_long <- fert %>%
  transmute(
    Year = as.integer(refYear),
    item = as.character(fertilizer),
    quantity = as.numeric(qty_merged_ton),
    category = "fertilizer"
  )

# 必要なら肥料名をわかりやすく変更
fert_long <- fert_long %>%
  mutate(
    item = case_when(
      item == "N" ~ "Fertilizer_N",
      item == "P" ~ "Fertilizer_P",
      item == "K" ~ "Fertilizer_K",
      TRUE ~ paste0("Fertilizer_", item)
    )
  )


# 3. 結合----

trade_all_long <- bind_rows(food_long, fert_long) %>%
  arrange(item, Year)

# 確認
print(trade_all_long)


# 4. wide化----
#   行 = 年、列 = 品目、値 = 数量(ton)

trade_all_wide <- trade_all_long %>%
  select(Year, item, quantity) %>%
  group_by(Year, item) %>%
  summarise(quantity = sum(quantity, na.rm = TRUE), .groups = "drop") %>%
  pivot_wider(
    names_from = item,
    values_from = quantity
  ) %>%
  arrange(Year)

print(trade_all_wide)


# 5. log差分を作成----
#   ln(x_t) - ln(x_{t-1})
#   quantity <= 0 は NA

make_logdiff <- function(x) {
  x <- as.numeric(x)
  x[x <= 0] <- NA_real_
  c(NA_real_, diff(log(x)))
}

trade_logdiff <- trade_all_wide %>%
  arrange(Year) %>%
  mutate(
    across(-Year, make_logdiff)
  )

print(trade_logdiff)


# 6. 線形トレンド除去----
#   各系列について y_t = a + b*t + e_t
#   の残差 e_t を使う

detrend_series <- function(y, year) {
  df <- tibble(y = as.numeric(y), Year = as.numeric(year)) %>%
    filter(!is.na(y), !is.na(Year))
  
  if (nrow(df) < 5) {
    out <- rep(NA_real_, length(y))
    return(out)
  }
  
  fit <- lm(y ~ Year, data = df)
  resid_vals <- resid(fit)
  
  out <- rep(NA_real_, length(y))
  valid_idx <- which(!is.na(y) & !is.na(year))
  out[valid_idx] <- resid_vals
  out
}

trade_logdiff_detrended <- trade_logdiff %>%
  mutate(
    across(-Year, ~ detrend_series(.x, Year))
  )

print(trade_logdiff_detrended)

# 6.5. 単位根検定----
#   Augmented Dickey-Fuller test を使用

run_adf_test <- function(x, name) {
  
  x <- as.numeric(x)
  x <- x[!is.na(x)]
  
  if (length(x) < 10) {
    return(tibble(
      item = name,
      p_value = NA_real_,
      statistic = NA_real_,
      n_obs = length(x),
      result = "Too few observations"
    ))
  }
  
  test <- tryCatch(
    adf.test(x),
    error = function(e) NULL
  )
  
  if (is.null(test)) {
    return(tibble(
      item = name,
      p_value = NA_real_,
      statistic = NA_real_,
      n_obs = length(x),
      result = "Error"
    ))
  }
  
  tibble(
    item = name,
    p_value = test$p.value,
    statistic = test$statistic,
    n_obs = length(x),
    result = ifelse(test$p.value < 0.05, "Stationary", "Non-stationary")
  )
}

#  全系列に適用
adf_results <- trade_logdiff_detrended %>%
  select(-Year) %>%
  imap_dfr(~ run_adf_test(.x, .y))

print(adf_results)

#  まとめ表（論文用）
adf_summary <- adf_results %>%
  summarise(
    n_series = n(),
    n_stationary = sum(result == "Stationary", na.rm = TRUE),
    share_stationary = mean(result == "Stationary", na.rm = TRUE)
  )

print(adf_summary)


# 7. 共分散行列・相関行列----
#   pairwise.complete.obs を使用

mat_detrended <- trade_logdiff_detrended %>%
  select(-Year) %>%
  as.matrix()

cov_matrix <- cov(mat_detrended, use = "pairwise.complete.obs")
cor_matrix <- cor(mat_detrended, use = "pairwise.complete.obs")

print(cov_matrix)
print(cor_matrix)


# 8. 欠損数チェック----

na_summary <- trade_logdiff_detrended %>%
  summarise(
    across(-Year, ~ sum(is.na(.x)))
  ) %>%
  pivot_longer(
    cols = everything(),
    names_to = "item",
    values_to = "n_NA"
  ) %>%
  arrange(desc(n_NA))

print(na_summary)

# 9. 断絶チェック----

plot_item <- function(df, item_name) {
  ggplot(df, aes(x = Year, y = .data[[item_name]])) +
    geom_line(linewidth = 0.8) +
    labs(title = item_name, y = "Quantity (ton)") +
    theme_minimal()
}

plot_item(trade_all_wide, "Wheat")
plot_item(trade_all_wide, "Fertilizer_N")

plot_item(trade_logdiff_detrended, "Wheat")
plot_item(trade_logdiff_detrended, "Fertilizer_N")

# 9. 保存----

write_csv(trade_all_long, "trade_all_long.csv")
write_csv(trade_all_wide, "trade_all_wide.csv")
write_csv(trade_logdiff, "trade_all_logdiff.csv")
write_csv(trade_logdiff_detrended, "trade_all_logdiff_detrended.csv")

write_csv(
  as.data.frame(cov_matrix) %>% tibble::rownames_to_column("item"),
  "cov_matrix_detrended_logdiff.csv"
)

write_csv(
  as.data.frame(cor_matrix) %>% tibble::rownames_to_column("item"),
  "cor_matrix_detrended_logdiff.csv"
)

library(MASS)
library(readr)
library(dplyr)
library(tidyr)


# 多変量正規ショック----

# 1. 設定----
set.seed(123)

n_sim <- 10000

# cov_matrix は前段で作成済みの共分散行列を想定
# 行名・列名が品目名になっている必要あり
items <- colnames(cov_matrix)

# 念のため対称化
Sigma <- as.matrix(cov_matrix)
Sigma <- (Sigma + t(Sigma)) / 2


# 2. 正定値性チェック----
eig <- eigen(Sigma, symmetric = TRUE)$values

if (any(eig < -1e-8)) {
  stop("Covariance matrix has negative eigenvalues. Check the covariance matrix.")
}

# 小さな数値誤差なら補正
if (any(eig < 0)) {
  Sigma <- Matrix::nearPD(Sigma)$mat
  Sigma <- as.matrix(Sigma)
}


# 3. 多変量正規ショックを生成----
#    epsilon_s ~ MVN(0, Sigma)

epsilon_mat <- MASS::mvrnorm(
  n = n_sim,
  mu = rep(0, length(items)),
  Sigma = Sigma
)

colnames(epsilon_mat) <- items


# 4. wide形式で保存----
#    行 = シナリオ、列 = 品目

epsilon_wide <- as.data.frame(epsilon_mat) %>%
  mutate(s = paste0("s", row_number())) %>%
  relocate(s)

write_csv(epsilon_wide, "epsilon_shocks_wide_sj_n10000.csv")


# 5. long形式で保存----

epsilon_long <- epsilon_wide %>%
  pivot_longer(
    cols = -s,
    names_to = "j",
    values_to = "epsilon"
  )

write_csv(epsilon_long, "epsilon_shocks_long_sj_n10000.csv")


# 6. gams形式で保存----
#    行 = 品目、列 = シナリオ

epsilon_long_gams <- epsilon_long %>%
  select(j, s, epsilon) %>%
  arrange(j, s)

write_csv(epsilon_long_gams, "epsilon_shocks_long_js_n10000.csv")

epsilon_wide_gams <- epsilon_long %>%
  select(j, s, epsilon) %>%
  pivot_wider(
    names_from = s,
    values_from = epsilon
  ) %>%
  arrange(j)

write_csv(epsilon_wide_gams, "epsilon_shocks_wide_js_n10000.csv")


# 7. 確認----
shock_summary <- epsilon_long %>%
  group_by(j) %>%
  summarise(
    mean_epsilon = mean(epsilon, na.rm = TRUE),
    sd_epsilon = sd(epsilon, na.rm = TRUE),
    p01 = quantile(epsilon, 0.01, na.rm = TRUE),
    p05 = quantile(epsilon, 0.05, na.rm = TRUE),
    p50 = quantile(epsilon, 0.50, na.rm = TRUE),
    p95 = quantile(epsilon, 0.95, na.rm = TRUE),
    p99 = quantile(epsilon, 0.99, na.rm = TRUE),
    .groups = "drop"
  )

write_csv(shock_summary, "epsilon_shock_summary_n10000.csv")
print(shock_summary)
