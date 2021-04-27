#!/bin/bash

# TinyTex本体のインストール
# 当面、FREEZEとなった TeXLive 2020 アーカイブを利用する

Rscript -e 'tinytex::install_tinytex(dir = "/home/rstudio/.TinyTeX/", version = "2021.03", repository = "https://texlive.texjp.org/2020/tlnet")'

# 一部の package 用にLaTeXコンパイラの場所を指定
echo "R_LATEXCMD=/home/rstudio/.TinyTeX/bin/x86_64-linux/platex" >> /home/rstudio/.Renviron
echo "R_PDFLATEXCMD=/home/rstudio/.TinyTeX/bin/x86_64-linux/pdflatex" >> /home/rstudio/.Renviron
