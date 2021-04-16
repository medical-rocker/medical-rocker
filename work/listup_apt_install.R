# apt でインストールするパッケージの抽出

# 準備：
# https://packagemanager.rstudio.com/client/#/repos/1/overview で Ubuntu 20.04 の
# Install System Prerequisites for the Repo’s Packages に記載されている内容を 
# system_prerequisites.txt として保存しておく
  
library(tidyverse)

# インストールするパッケージのリスト
source("work/listup_install_packages.R")
rm(list = setdiff(ls(), "list_finally_install"))

tbl_prerequisites <- readLines("work/system_prerequisites.txt") %>%
  # 'R CMD javareconf' は削除
  str_remove_all("R CMD javareconf") %>% 
  # パッケージごとにまとめる
  str_c(collapse = "@@") %>% 
  str_split("# ") %>% 
  unlist() %>%
  .[-1] %>% 
  as_tibble() %>%
  # パッケージ名と依存情報を分ける
  # 依存情報は apt-get install -y の部分を省略
  mutate(
    # パッケージ名は最初の空白まで
    pkg  = map_chr(value, ~str_extract(., '^([^ ]*)')),
    # requirements: の行のあとを分解してaptパッケージ名を抽出
    req  = map_chr(value, ~str_split(., "requirements:@@", simplify = TRUE)[2]),
    reqs = map(req,  ~str_split(., "@@", simplify = TRUE)),
    reqs = map(reqs, ~str_replace_all(., 'apt-get install -y (.+)', '\\1')),
    reqs = map(reqs, ~ifelse(. == "", NA_character_, .))
  ) %>% 
  dplyr::select(pkg, reqs) %>% 
  unnest(cols = reqs) %>% 
  drop_na(reqs)

# インストールするRパッケージに関連するものに絞る
list_apt_install <- tbl_prerequisites %>% 
  dplyr::filter(pkg %in% list_finally_install) %>% 
  # aptパッケージ名を取り出す
  dplyr::select(reqs) %>% 
  unnest(cols = reqs) %>% 
  drop_na() %>% 
  pull(reqs) %>% 
  unique() %>% 
  sort()
  
list_apt_install

#  [1] "bwidget"              "default-jdk"          "gdal-bin"            
#  [4] "imagemagick"          "libcairo2-dev"        "libcurl4-openssl-dev"
#  [7] "libfontconfig1-dev"   "libfreetype6-dev"     "libfribidi-dev"      
# [10] "libgdal-dev"          "libgeos-dev"          "libgl1-mesa-dev"     
# [13] "libglpk-dev"          "libglu1-mesa-dev"     "libgmp3-dev"         
# [16] "libharfbuzz-dev"      "libjpeg-dev"          "libmagick++-dev"     
# [19] "libmysqlclient-dev"   "libpng-dev"           "libproj-dev"         
# [22] "librsvg2-dev"         "libssl-dev"           "libtiff-dev"         
# [25] "libudunits2-dev"      "libv8-dev"            "libxml2-dev"         
# [28] "make"                 "mysql-server"         "pandoc"              
# [31] "pandoc-citeproc"      "perl"                 "texlive"             
# [34] "zlib1g-dev"
