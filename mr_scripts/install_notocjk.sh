#!/bin/bash

# Noto Sans/Serif CJK JP フォントのインストール

set -x

# apt-get install fonts-notocjk-extra とすると 300MBくらい必要なので、
# zxjafont.sty の 'noto' オプションで使用する7書体と等幅のRegularのみ手動インストール

wget https://noto-website-2.storage.googleapis.com/pkgs/NotoSansCJKjp-hinted.zip
wget https://noto-website-2.storage.googleapis.com/pkgs/NotoSerifCJKjp-hinted.zip
unzip NotoSansCJKjp-hinted.zip NotoSans*.otf
unzip NotoSerifCJKjp-hinted.zip NotoSerif*.otf

mkdir /usr/share/fonts/noto
mv NotoSerifCJKjp-Light.otf /usr/share/fonts/noto/
mv NotoSerifCJKjp-Regular.otf /usr/share/fonts/noto/
mv NotoSerifCJKjp-Bold.otf /usr/share/fonts/noto/
mv NotoSansCJKjp-Regular.otf /usr/share/fonts/noto/
mv NotoSansCJKjp-Bold.otf /usr/share/fonts/noto/
mv NotoSansCJKjp-Black.otf /usr/share/fonts/noto/
mv NotoSansCJKjp-Medium.otf /usr/share/fonts/noto/
mv NotoSansMonoCJKjp-Regular.otf /usr/share/fonts/noto/

chmod 644 /usr/share/fonts/noto/*
fc-cache -fv
rm Noto*

# 標準フォントとして手動で入れた Noto fonts を認識できるようにする
# 設定しておけば、最低限グラフの文字化けはなくなる

mkdir -p /home/rstudio/.config/fontconfig
cp /my_scripts/fonts.conf /home/rstudio/.config/fontconfig/
chown -R rstudio:rstudio /home/rstudio/.config
