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

#  [1] "libcairo2-dev"        "libcurl4-openssl-dev" "libfontconfig1-dev"  
#  [4] "libfreetype6-dev"     "libglpk-dev"          "libgmp3-dev"         
#  [7] "libjpeg-dev"          "libpng-dev"           "libssl-dev"          
# [10] "libv8-dev"            "libxml2-dev"          "make"                
# [13] "pandoc"               "pandoc-citeproc"      "perl"           

## install.packages(..., dependencies = TRUE) の場合
#  [1] "default-jdk"          "gdal-bin"             "imagemagick"         
#  [4] "libcairo2-dev"        "libcurl4-openssl-dev" "libfontconfig1-dev"  
#  [7] "libfreetype6-dev"     "libfribidi-dev"       "libgdal-dev"         
# [10] "libgeos-dev"          "libgl1-mesa-dev"      "libglpk-dev"         
# [13] "libglu1-mesa-dev"     "libgmp3-dev"          "libharfbuzz-dev"     
# [16] "libjpeg-dev"          "libmagick++-dev"      "libmysqlclient-dev"  
# [19] "libpng-dev"           "libproj-dev"          "librsvg2-dev"        
# [22] "libssl-dev"           "libtiff-dev"          "libudunits2-dev"     
# [25] "libv8-dev"            "libxml2-dev"          "make"                
# [28] "mysql-server"         "pandoc"               "pandoc-citeproc"     
# [31] "perl"                 "texlive"              "zlib1g-dev"          

# インストール済 deb/apt パッケージ
list_already_installed <- gsub('^([^/]+).*', '\\1', system("apt list --installed", intern = T))

# インストールされていない必要パッケージ
setdiff(list_apt_install, list_already_installed)

# [1] "libglpk-dev"     "libgmp3-dev"     "libjpeg-dev"     "libv8-dev"      
# [5] "pandoc"          "pandoc-citeproc"

## install.packages(..., dependencies = TRUE) の場合
#  [1] "default-jdk"      "gdal-bin"         "imagemagick"      "libfribidi-dev"  
#  [5] "libgdal-dev"      "libgeos-dev"      "libgl1-mesa-dev"  "libglpk-dev"     
#  [9] "libglu1-mesa-dev" "libgmp3-dev"      "libharfbuzz-dev"  "libjpeg-dev"     
# [13] "libmagick++-dev"  "libproj-dev"      "librsvg2-dev"     "libtiff-dev"     
# [17] "libudunits2-dev"  "libv8-dev"        "mysql-server"     "pandoc"          
# [21] "pandoc-citeproc"  "texlive"         

# うち、pandoc は rocker/rstudio で RStudio server インストール時に手動インストール済
# texlive は TinyTex で別途インストールする
