library(readr)
library(dplyr)
library(stringr)
library(tidyr)
library(ggplot2)

# 日本の輸入データ----
## 1. データ読込----

fao_jpn <- read_csv("FAOSTAT_data_en_japan.csv", show_col_types = FALSE)


## 2. Import quantity のみ抽出----

imp <- fao_jpn %>%
  filter(Element == "Import quantity") %>%
  mutate(Item = str_trim(Item))


## 3. Item を大分類に対応付け----
#   必要に応じて追加修正

imp_pick <- imp %>%
  mutate(item_group = case_when(
    
    # 米
    Item %in% c("Rice",
                "Rice, milled",
                "Rice, milled (husked)",
                "Rice, paddy (rice milled equivalent)",
                "Husked rice",
                "Rice, broken") ~ "Rice",
    
    # 小麦
    Item %in% c("Wheat",
                "Wheat and meslin flour") ~ "Wheat",
    
    # 大麦
    Item %in% c("Barley",
                "Barley, pearled") ~ "Barley",
    
    # トウモロコシ
    Item %in% c("Maize (corn)",
                "Green corn (maize)") ~ "Maize",
    
    # ソルガム
    Item %in% c("Sorghum") ~ "Sorghum",
    
    # かんしょ
    Item %in% c("Sweet potatoes") ~ "Sweet potatoes",
    
    # ばれいしょ
    Item %in% c("Potatoes",
                "Potatoes, frozen",
                "Flour, meal, powder, flakes, granules and pellets of potatoes") ~ "Potatoes",
    
    # 大豆
    Item %in% c("Soya beans",
                "Cake of soya beans") ~ "Soybeans",
    
    # りんご
    Item %in% c("Apples",
                "Apple juice",
                "Apple juice, concentrated") ~ "Apples",
    
    # 菜種
    Item %in% c("Rape or colza seed",
                "Cake of rapeseed") ~ "Rapeseed",
    
    # でんぷん
    Item %in% c("Starch of cassava",
                "Edible roots and tubers with high starch or inulin content, n.e.c., fresh") ~ "Starch",
    
    # 粗糖
    Item %in% c("Raw cane or beet sugar (centrifugal only)",
                "Cane sugar, non-centrifugal",
                "Refined cane or beet sugar, in solid form, containing added flavouring or colouring matter; maple sugar and maple syrup",
                "Refined sugar",
                "Sugar and syrups n.e.c.") ~ "Raw sugar",
    
    # 油
    Item %in% c("Soya bean oil",
                "Rapeseed or canola oil, crude",
                "Palm oil",
                "Olive oil",
                "Oil of maize",
                "Oil of rice bran",
                "Sunflower-seed oil, crude",
                "Groundnut oil",
                "Coconut oil",
                "Cottonseed oil",
                "Other oil of vegetable origin, crude n.e.c.",
                "Animal oils and fats n.e.c.") ~ "Oils",
    
    # 牛肉
    Item %in% c("Beef and veal preparations nes",
                "Bovine meat, salted, dried or smoked") ~ "Beef",
    
    # 豚肉
    Item %in% c("Meat of pig boneless, fresh or chilled",
                "Meat of pig with the bone, fresh or chilled",
                "Pig meat preparations",
                "Pig meat, cuts, salted, dried or smoked (bacon and ham)") ~ "Pork",
    
    # 鶏肉
    Item %in% c("Meat of chickens, fresh or chilled",
                "Poultry meat preparations") ~ "Chicken",
    
    # 乳製品
    Item %in% c("Butter of cow milk",
                "Buttermilk, curdled and acidified milk",
                "Buttermilk, dry",
                "Cheese from whole cow milk",
                "Processed cheese",
                "Cream, fresh",
                "Raw milk of cattle",
                "Skim milk and whey powder",
                "Skim milk of cows",
                "Whole milk powder",
                "Whole milk, condensed",
                "Whole milk, evaporated",
                "Whey, condensed",
                "Whey, dry",
                "Yoghurt, with additives") ~ "Dairy products",
    
    TRUE ~ NA_character_
  )) %>%
  filter(!is.na(item_group))


## 4. どの Item が拾われたか確認----

item_mapping <- imp_pick %>%
  distinct(item_group, Item) %>%
  arrange(item_group, Item)

print(item_mapping, n = Inf)


## 5. 必要なら年次集計----

imp_grouped <- imp_pick %>%
  group_by(Year, item_group) %>%
  summarise(Value = sum(Value, na.rm = TRUE), .groups = "drop")

print(imp_grouped)


## 6. 保存----

write_csv(item_mapping, "FAO_japan_item_mapping_selected.csv")
write_csv(imp_grouped, "FAO_japan_import_selected_grouped.csv")



# 全世界貿易データ----
## 1. 品目マップ関数----
#    imp_pick.txt の確定版をそのまま反映

map_fao_item_group <- function(item_vec) {
  case_when(
    # 米
    item_vec %in% c("Rice",
                    "Rice, milled",
                    "Rice, milled (husked)",
                    "Rice, paddy (rice milled equivalent)",
                    "Husked rice",
                    "Rice, broken") ~ "Rice",
    
    # 小麦
    item_vec %in% c("Wheat",
                    "Wheat and meslin flour") ~ "Wheat",
    
    # 大麦
    item_vec %in% c("Barley",
                    "Barley, pearled") ~ "Barley",
    
    # トウモロコシ
    item_vec %in% c("Maize (corn)",
                    "Green corn (maize)") ~ "Maize",
    
    # ソルガム
    item_vec %in% c("Sorghum") ~ "Sorghum",
    
    # かんしょ
    item_vec %in% c("Sweet potatoes") ~ "Sweet potatoes",
    
    # ばれいしょ
    item_vec %in% c("Potatoes",
                    "Potatoes, frozen",
                    "Flour, meal, powder, flakes, granules and pellets of potatoes") ~ "Potatoes",
    
    # 大豆
    item_vec %in% c("Soya beans",
                    "Cake of soya beans") ~ "Soybeans",
    
    # りんご
    item_vec %in% c("Apples",
                    "Apple juice",
                    "Apple juice, concentrated") ~ "Apples",
    
    # 菜種
    item_vec %in% c("Rape or colza seed",
                    "Cake of rapeseed") ~ "Rapeseed",
    
    # でんぷん
    item_vec %in% c("Starch of cassava",
                    "Edible roots and tubers with high starch or inulin content, n.e.c., fresh") ~ "Starch",
    
    # 粗糖
    item_vec %in% c("Raw cane or beet sugar (centrifugal only)",
                    "Cane sugar, non-centrifugal",
                    "Refined cane or beet sugar, in solid form, containing added flavouring or colouring matter; maple sugar and maple syrup",
                    "Refined sugar",
                    "Sugar and syrups n.e.c.") ~ "Raw sugar",
    
    # 油
    item_vec %in% c("Soya bean oil",
                    "Rapeseed or canola oil, crude",
                    "Palm oil",
                    "Olive oil",
                    "Oil of maize",
                    "Oil of rice bran",
                    "Sunflower-seed oil, crude",
                    "Groundnut oil",
                    "Coconut oil",
                    "Cottonseed oil",
                    "Other oil of vegetable origin, crude n.e.c.",
                    "Animal oils and fats n.e.c.") ~ "Oils",
    
    # 牛肉
    item_vec %in% c("Beef and veal preparations nes",
                    "Bovine meat, salted, dried or smoked") ~ "Beef",
    
    # 豚肉
    item_vec %in% c("Meat of pig boneless, fresh or chilled",
                    "Meat of pig with the bone, fresh or chilled",
                    "Pig meat preparations",
                    "Pig meat, cuts, salted, dried or smoked (bacon and ham)") ~ "Pork",
    
    # 鶏肉
    item_vec %in% c("Meat of chickens, fresh or chilled",
                    "Poultry meat preparations") ~ "Chicken",
    
    # 乳製品
    item_vec %in% c("Butter of cow milk",
                    "Buttermilk, curdled and acidified milk",
                    "Buttermilk, dry",
                    "Cheese from whole cow milk",
                    "Processed cheese",
                    "Cream, fresh",
                    "Raw milk of cattle",
                    "Skim milk and whey powder",
                    "Skim milk of cows",
                    "Whole milk powder",
                    "Whole milk, condensed",
                    "Whole milk, evaporated",
                    "Whey, condensed",
                    "Whey, dry",
                    "Yoghurt, with additives") ~ "Dairy products",
    
    TRUE ~ NA_character_
  )
}


## 2. FAOSTAT世界貿易データを集計する関数----
#    import / export の両方に使える

aggregate_fao_world_trade <- function(file,
                                      element_filter = NULL,
                                      year_col = "Year",
                                      item_col = "Item",
                                      element_col = "Element",
                                      value_col = "Value",
                                      area_col = "Area",
                                      encoding = "UTF-8") {
  
  dat <- read_csv(
    file,
    locale = locale(encoding = encoding),
    show_col_types = FALSE
  )
  
  # 必須列確認
  req_cols <- c(year_col, item_col, element_col, value_col)
  miss_cols <- setdiff(req_cols, names(dat))
  if (length(miss_cols) > 0) {
    stop("Missing required columns: ", paste(miss_cols, collapse = ", "))
  }
  
  out <- dat %>%
    mutate(
      Year = as.integer(.data[[year_col]]),
      Item = str_trim(as.character(.data[[item_col]])),
      Element = as.character(.data[[element_col]]),
      Value = as.numeric(.data[[value_col]]),
      item_group = map_fao_item_group(Item)
    )
  
  # 必要なら Element を絞る
  if (!is.null(element_filter)) {
    out <- out %>%
      filter(Element == element_filter)
  }
  
  # マップされた品目だけ残して年次集計
  out_grouped <- out %>%
    filter(!is.na(item_group)) %>%
    group_by(Year, item_group) %>%
    summarise(
      Value = sum(Value, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    arrange(item_group, Year)
  
  # 元の Item と集約先の対応表
  item_mapping <- out %>%
    filter(!is.na(item_group)) %>%
    distinct(item_group, Item) %>%
    arrange(item_group, Item)
  
  # カバー状況
  coverage <- out %>%
    summarise(
      n_all_rows = n(),
      n_mapped_rows = sum(!is.na(item_group)),
      share_mapped_rows = mean(!is.na(item_group))
    )
  
  list(
    grouped = out_grouped,
    item_mapping = item_mapping,
    coverage = coverage
  )
}

library(ggplot2)
library(dplyr)

## 4. 任意の品目を時系列プロットする関数----

plot_fao_item_series <- function(grouped_df,
                                 item_name,
                                 value_col = "Value",
                                 year_col = "Year",
                                 item_group_col = "item_group",
                                 y_label = "Quantity",
                                 title = NULL) {
  
  plot_df <- grouped_df %>%
    filter(.data[[item_group_col]] == item_name) %>%
    arrange(.data[[year_col]])
  
  if (nrow(plot_df) == 0) {
    stop("No data found for item_name = ", item_name)
  }
  
  if (is.null(title)) {
    title <- paste("Time series of", item_name)
  }
  
  ggplot(plot_df, aes(x = .data[[year_col]], y = .data[[value_col]])) +
    geom_line(linewidth = 0.8) +
    labs(
      title = title,
      x = "Year",
      y = y_label
    ) +
    theme_minimal()
}

## 世界輸出データを集計して保存----
res_export <- aggregate_fao_world_trade(
  file = "FAOSTAT_data_en_world_export.csv"
)

res_export$grouped
res_export$item_mapping
res_export$coverage

plot_fao_item_series(
  grouped_df = res_export$grouped,
  item_name = "Wheat",
  y_label = "Export quantity"
)

plot_fao_item_series(
  grouped_df = res_export$grouped,
  item_name = "Soybeans",
  y_label = "Export quantity"
)

write_csv(res_export$grouped, "world_export_grouped.csv")
write_csv(res_export$item_mapping, "world_export_item_mapping.csv")


## 世界輸入データを集計して保存----
res_import <- aggregate_fao_world_trade(
  file = "FAOSTAT_data_en_world_import.csv"
)

res_import$grouped
res_import$item_mapping
res_import$coverage

plot_fao_item_series(
  grouped_df = res_import$grouped,
  item_name = "Wheat",
  y_label = "Import quantity"
)

plot_fao_item_series(
  grouped_df = res_import$grouped,
  item_name = "Soybeans",
  y_label = "Import quantity"
)

write_csv(res_import$grouped, "world_import_grouped.csv")
write_csv(res_import$item_mapping, "world_import_item_mapping.csv")
