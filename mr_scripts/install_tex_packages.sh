#!/bin/bash

# XeLaTeX + BXjscls で日本語PDFを作成するのに必要なパッケージのインストール

/home/rstudio/.TinyTeX/bin/x86_64-linux/tlmgr install \
    bxjscls \
    zxjatype \
    zxjafont \
    adobemapping \
    amscls \
    arphic \
    beamer \
    cjk \
    cjkpunct \
    cns \
    ctablestack \
    ctex \
    everyhook \
    fandol \
    fonts-tlwg \
    fp \
    garuda-c90 \
    latex-base-dev \
    luatexbase \
    luatexja \
    mptopdf.x86_64-linux \
    mptopdf \
    ms \
    norasi-c90 \
    pgf \
    platex.x86_64-linux \
    platex \
    platex-tools \
    ptex.x86_64-linux \
    ptex \
    ptex-base \
    ptex-fonts \
    svn-prov \
    translator \
    ttfutils.x86_64-linux \
    ttfutils \
    uhc \
    ulem \
    uplatex.x86_64-linux \
    uplatex \
    uptex.x86_64-linux \
    uptex \
    uptex-base \
    uptex-fonts \
    wadalab \
    xcjk2uni \
    xecjk \
    xpinyin \
    zhmetrics \
    zhmetrics-uptex \
    zhnumber

/home/rstudio/.TinyTeX/bin/x86_64-linux/tlmgr path add
