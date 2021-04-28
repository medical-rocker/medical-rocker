#!/bin/bash

# R パッケージのインストール

set -x

# 依存ライブラリの追加
apt-get update
apt-get install -y --no-install-recommends \
    default-jdk \
	imagemagick \
	gdal-bin \
	libmagick++-dev \
	libfribidi-dev \
	libgdal-dev \
	libgeos-dev \
	libgl1-mesa-dev \
	libglpk-dev \
	libglu1-mesa-dev \
	libgmp3-dev \
	libharfbuzz-dev \
	libjpeg-dev \
	libproj-dev \
	librsvg2-dev \
	libtiff-dev \
	libudunits2-dev \
	libv8-dev \
	mysql-server \
	libtcl8.6 \
	libtk8.6

apt-get clean
rm -rf /var/lib/apt/lists/*

# rJava の設定
R CMD javareconf

# RSPMのcheckpointが変わった場合に対応するため、まずcheckpointの状態まで更新する
Rscript -e "update.packages(ask = FALSE)"

# 依存関係でCRAN/RSPMにないもの（Bioconductor）を先にインストール
Rscript -e "BiocManager::install(c('limma'))"

# CRANパッケージをRSPMからインストール

# Causal Inference Slack で募集されたもの
# https://docs.google.com/spreadsheets/d/175Q_lzNG7P6TT2k9rUzzweoaKdJS_OJZ3lWpUuTfcvc/edit#gid=0
# のうち、rocker/tidyverse:4.0.4 にインストール済のものは除外

# 大分類「表関係」
install2.r --error --deps TRUE --ncpus -1 --skipinstalled \
    finalfit \
	flextable \
	formattable \
	ftExtra \
	gtsummary \
	tableone

# 大分類「図関連」
install2.r --error --deps TRUE --ncpus -1 --skipinstalled \
	beeswarm \
	DiagrammeR \
	forestplot \
	GGally \
	ggbeeswarm \
	ggforce \
	ggfortify \
	gghighlight \
	ggpubr \
	ggrepel \
	ggridges \
	ggsci \
	patchwork \
	plotly

# 大分類「解析」中分類「統計学」
install2.r --error --deps TRUE --ncpus -1 --skipinstalled \
	car \
	cmprsk \
	coin \
	emmeans \
	geepack \
	infer \
	lme4 \
	lmerTest \
	logistf \
	MKmisc \
	mvtnorm \
	rsample \
	survey \
	survminer \
	tidymodels \
	tmvtnorm \
	interactions

# 大分類「解析」その他
install2.r --error --deps TRUE --ncpus -1 --skipinstalled \
	Amelia \
	mice \
	caret \
	glmnet \
	glmnetUtils \
	partykit \
	pROC \
	Epi \
	epiR \
	cobalt \
	Matching \
	MatchIt \
	WeightIt \
	gfoRmula \
	LaplacesDemon \
	rstan

# その他
install2.r --error --deps TRUE --ncpus -1 --skipinstalled \
	janitor \
	rebus \
	sqldf \
	tidylog \
	comorbidity \
	furrr \
	here \
	zipangu \
    palmerpenguins \
    styler

# R.cache (imported by styler) で使用するキャッシュディレクトリを準備
mkdir -p /home/rstudio/.cache/R/R.cache
chown -R rstudio:rstudio /home/rstudio/.cache

# cleaning
rm /tmp/downloaded_packages/*
