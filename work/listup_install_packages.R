# Rパッケージの追加に必要な apt パッケージを抽出する
# 素の rocker/tidyverse 上で実行する

library(tidyverse)

# インストールするパッケージの候補
# https://docs.google.com/spreadsheets/d/175Q_lzNG7P6TT2k9rUzzweoaKdJS_OJZ3lWpUuTfcvc/edit#gid=0
# 「おすすめされたPackage」列をコピー

# 「スコープ外」の psych, AMR, PredictABEL は除外する

list_candidates <- 
  "
  finalfit
  flextable
  formattable
  ftExtra
  gtsummary
  tableone
  boot
  car
  cmprsk
  coin
  emmeans
  geepack
  infer
  lme4
  lmerTest
  logistf
  MASS
  MKmisc
  mvtnorm
  rsample
  survey
  survival
  survminer
  tidymodels
  tmvtnorm
  interactions
  beeswarm
  DiagrammeR
  forestplot
  GGally
  ggbeeswarm
  ggforce
  ggfortify
  gghighlight
  ggpubr
  ggrepel
  ggridges
  ggsci
  patchwork
  plotly
  RColorBrewer
  Amelia
  mice
  caret
  glmnet
  glmnetUtils
  partykit
  pROC
  rpart
  Epi
  epiR
  cobalt
  Matching
  MatchIt
  WeightIt
  gfoRmula
  LaplacesDemon
  rstan
  broom
  data.table
  haven
  janitor
  rebus
  sqldf
  tidylog
  tidyverse
  comorbidity
  furrr
  here
  zipangu
  " %>%
  str_trim() %>% 
  str_split('\n(\ )*', simplify = TRUE)

# CRAN (RSPM) のパッケージ一覧
tbl_cran <- available.packages() %>% as_tibble()

#> list_candidates[!(list_candidates %in% tbl_cran$Package)]
#[1] "optim"         "RcolorBrewear" "cmdstanr"      "laplacesdemon" "icd"

# optim -> stats::optim()                                    # 'optim' is not a package
# RcolorBrewear -> RColorBrewer                              # typo
# cmdstanr -> remotes::install_github("stan-dev/cmdstanr")   # not in CRAN
# laplacesdemon -> LaplacesDemon                             # typo
# icd -> remotes::install_github("jackwasey/icd/")           # removed from CRAN

# 上記 typo を修正の上、インストール候補のうち rocker/tidyverse にないものを残す
list_will_install <- list_candidates[!(list_candidates %in% .packages(all.available = TRUE))]

# 依存パッケージのリスト
tbl_dependencies <- tbl_cran %>% 
  # 関連パッケージの情報に絞る
  dplyr::select(Package, Depends, Imports, LinkingTo, Suggests) %>% 
  # 縦持ちに変換
  pivot_longer(
    cols      = Depends:Suggests,
    names_to  = "category",
    values_to = "pkgs"
  ) %>%
  mutate(
    pkgs = str_split(pkgs, ", ")
  ) %>% 
  unnest(cols = pkgs) %>% 
  drop_na(pkgs) %>% 
  # バージョン表記を削除
  mutate(
    pkgs = str_remove_all(pkgs, '\ (.+)')
  ) %>% 
  # Depends == "R" は削除
  dplyr::filter(pkgs != "R")

# インストールが必要なパッケージを順に抽出していく
list_to_install <- list()

## まずはインストール候補
list_to_install <- c(list_to_install, list(list_will_install))

### install.packages(pkgs, dependencies = TRUE) でインストールされるもの
###  pkgs に対しては、Depends, Imports, LinkingTo, Suggests
###  追加されたものについて、さらに Depends, Imports, LinkingTo

## インストール候補の依存関係
list_to_install <- tbl_dependencies %>% 
  dplyr::filter(Package %in% list_to_install[[1]]) %>%
  # もともとインストールされているものは除く
  dplyr::filter(!(pkgs %in% .packages(all.available = TRUE))) %>%
  # インストール候補にあるものも除く
  dplyr::filter(!(pkgs %in% unlist(list_to_install))) %>% 
  pull(pkgs) %>% 
  unique() %>% 
  sort() %>% 
  list() %>% 
  c(list_to_install, .)

# 更に追加されるものがなくなるまで繰り返し
while(TRUE){
  temp <- tbl_dependencies %>% 
    dplyr::filter(Package %in% list_to_install[[length(list_to_install)]]) %>%
    # Suggests は除く
    dplyr::filter(category != "Suggests") %>% 
    # もともとインストールされているものは除く
    dplyr::filter(!(pkgs %in% .packages(all.available = TRUE))) %>%
    # インストール候補にあるものも除く
    dplyr::filter(!(pkgs %in% unlist(list_to_install))) %>% 
    pull(pkgs) %>% 
    unique() %>% 
    sort()
  
  # 追加するものがなくなったらループを抜ける
  if (length(temp) > 0) {
    list_to_install <- c(list_to_install, list(temp))
  } else {
    break
  }
}

# 最終的にインストールされるパッケージのリスト
list_finally_install <- list_to_install %>% 
  unlist() %>% 
  unique() %>% 
  sort()

# > length(list_finally_install)
# [1] 461

# CRAN (RSPM) 以外にあるもの
# > setdiff(list_finally_install, tbl_cran$Package)
# [1] "limma" "sbw"      

# limma は BioConductor にある
# sbw は CRAN から削除され利用不可
#   cobalt の Suggests なので 動作に不可欠ではない（最新版では削除されている様子）
