library(readr)
library(dplyr)
library(tidyr)
library(ggplot2)

# 1. 単一ファイルを読み、Exportのみ年次集計する関数----
read_and_aggregate_trade <- function(file,
                                     flow = "Export",
                                     year_col = "refYear",
                                     flow_col = "flowDesc",
                                     qty_col = "qty",
                                     encoding = "Latin1") {
  
  dat <- read_csv(file,
                  locale = locale(encoding = encoding),
                  show_col_types = FALSE)
  
  dat %>%
    transmute(
      refYear = as.integer(.data[[year_col]]),
      flowDesc = as.character(.data[[flow_col]]),
      qty = as.numeric(.data[[qty_col]])
    ) %>%
    filter(flowDesc == flow) %>%
    group_by(refYear) %>%
    summarise(qty = sum(qty, na.rm = TRUE), .groups = "drop") %>%
    arrange(refYear)
}

# 2. 562優先 + 条件付きで561採用 + 561補完----
#    ratio_threshold 未満なら「562 << 561」と見なして561採用
merge_sitc_series <- function(file_562,
                              file_561,
                              fertilizer_name = "fertilizer",
                              flow = "Export",
                              encoding = "Latin1",
                              ratio_threshold = 0.8) {
  
  y562 <- read_and_aggregate_trade(
    file = file_562,
    flow = flow,
    encoding = encoding
  ) %>%
    rename(qty_562 = qty)
  
  y561 <- read_and_aggregate_trade(
    file = file_561,
    flow = flow,
    encoding = encoding
  ) %>%
    rename(qty_561 = qty)
  
  merged <- full_join(y562, y561, by = "refYear") %>%
    arrange(refYear) %>%
    mutate(
      ratio_562_to_561 = if_else(!is.na(qty_562) & !is.na(qty_561) & qty_561 != 0,
                                 qty_562 / qty_561,
                                 NA_real_),
      
      # 562が561より著しく小さい年を判定
      prefer_561 = if_else(!is.na(ratio_562_to_561) & ratio_562_to_561 < ratio_threshold,
                           TRUE, FALSE, missing = FALSE),
      
      qty_merged_kg = case_when(
        !is.na(qty_562) & !is.na(qty_561) & prefer_561 ~ qty_561,  # 562 << 561 なら561採用
        !is.na(qty_562) ~ qty_562,                                 # 通常は562優先
        is.na(qty_562) & !is.na(qty_561) ~ qty_561,               # 562欠損時は561補完
        TRUE ~ NA_real_
      ),
      
      source_used = case_when(
        !is.na(qty_562) & !is.na(qty_561) & prefer_561 ~ "561_preferred",
        !is.na(qty_562) ~ "562",
        is.na(qty_562) & !is.na(qty_561) ~ "561_fallback",
        TRUE ~ NA_character_
      ),
      
      qty_merged_ton = qty_merged_kg / 1000,
      fertilizer = fertilizer_name
    )
  
  overlap_check <- merged %>%
    filter(!is.na(qty_562), !is.na(qty_561)) %>%
    mutate(
      diff_pct = 100 * (qty_562 - qty_561) / qty_561,
      fertilizer = fertilizer_name
    )
  
  overlap_summary <- overlap_check %>%
    summarise(
      fertilizer = fertilizer_name,
      n_overlap = n(),
      mean_ratio = mean(ratio_562_to_561, na.rm = TRUE),
      median_ratio = median(ratio_562_to_561, na.rm = TRUE),
      min_ratio = min(ratio_562_to_561, na.rm = TRUE),
      max_ratio = max(ratio_562_to_561, na.rm = TRUE),
      mean_diff_pct = mean(diff_pct, na.rm = TRUE),
      n_prefer_561 = sum(prefer_561, na.rm = TRUE),
      threshold_used = ratio_threshold
    )
  
  switched_years <- merged %>%
    filter(source_used == "561_preferred") %>%
    select(refYear, qty_562, qty_561, ratio_562_to_561, fertilizer)
  
  list(
    merged = merged,
    overlap_check = overlap_check,
    overlap_summary = overlap_summary,
    switched_years = switched_years
  )
}

# 3. 可視化関数----
plot_merged_series <- function(merged_df, title = NULL) {
  plot_df <- merged_df %>%
    select(refYear, qty_562, qty_561, qty_merged_kg) %>%
    pivot_longer(
      cols = c(qty_562, qty_561, qty_merged_kg),
      names_to = "series",
      values_to = "qty_kg"
    )
  
  ggplot(plot_df, aes(x = refYear, y = qty_kg, color = series)) +
    geom_line(linewidth = 0.8) +
    labs(
      title = title,
      x = "Year",
      y = "Quantity (kg)",
      color = "Series"
    ) +
    theme_minimal()
}

# 4. Nitrogen実行----
res_N <- merge_sitc_series(
  file_562 = "TradeData_all2world_SITC5621.csv",
  file_561 = "TradeData_all2world_SITC5611.csv",
  fertilizer_name = "N",
  ratio_threshold = 0.8
)

res_N$overlap_summary
res_N$switched_years
head(res_N$merged)
plot_merged_series(res_N$merged, title = "Nitrogen fertilizer exports")

# 5. Phosphate実行----
res_P <- merge_sitc_series(
  file_562 = "TradeData_all2world_SITC5622.csv",
  file_561 = "TradeData_all2world_SITC5612.csv",
  fertilizer_name = "P",
  ratio_threshold = 0.8
)

res_P$overlap_summary
res_P$switched_years
head(res_P$merged)
plot_merged_series(res_P$merged, title = "Phosphate fertilizer exports")

# 6. Potash実行----
res_K <- merge_sitc_series(
  file_562 = "TradeData_all2world_SITC5623.csv",
  file_561 = "TradeData_all2world_SITC5613.csv",
  fertilizer_name = "K",
  ratio_threshold = 0.8
)

res_K$overlap_summary
res_K$switched_years
head(res_K$merged)
plot_merged_series(res_K$merged, title = "Potash fertilizer exports")

#7. N・P・Kをまとめる----
fertilizer_all <- bind_rows(
  res_N$merged,
  res_P$merged,
  res_K$merged
)

write_csv(fertilizer_all, "fertilizer_exports_merged_all.csv")

