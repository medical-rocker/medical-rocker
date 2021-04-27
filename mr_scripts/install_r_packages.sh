#!/bin/bash

# R パッケージのインストール

set -x

# 依存ライブラリの追加
apt-get update
apt-get install -y --no-install-recommends \
    imagemagick \

apt-get clean
rm -rf /var/lib/apt/lists/*

# rJava の設定
R CMD javareconf

# RSPMのcheckpointが変わった場合に対応するため、まずcheckpointの状態まで更新する
Rscript -e "update.packages(ask = FALSE)"

# Bioconductor もRSPMからインストールする
echo "options(BioC_mirror = 'https://packagemanager.rstudio.com/bioconductor')" >> /usr/local/lib/R/etc/Rprofile.site
Rscript -e "BiocManager::install(c('graph', 'Rgraphviz'))"

# CRANパッケージをRSPMからインストール
install2.r --error --deps TRUE --ncpus -1 --skipinstalled \
    palmerpenguins \
    styler

# R.cache (imported by styler) で使用するキャッシュディレクトリを準備
mkdir -p /home/rstudio/.cache/R/R.cache
chown -R rstudio:rstudio /home/rstudio/.cache

# cleaning
rm /tmp/downloaded_packages/*
