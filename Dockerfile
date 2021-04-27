# rocker/tidyverse を元に、医学系臨床研究で有用なパッケージを導入した docker image

# CRAN snapshot : https://packagemanager.rstudio.com/cran/__linux__/focal/2021-03-30
FROM rocker/tidyverse:4.0.4

# Ubuntuミラーサイトの設定（自動選択）
RUN sed -i.bak -e 's%http://[^ ]\+%mirror://mirrors.ubuntu.com/mirrors.txt%g' /etc/apt/sources.list

# 日本語設定と必要なライブラリ（Rパッケージ用は別途スクリプト内で導入）
RUN set -x \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        language-pack-ja-base \
        locales \
        libxt6 \
        ssh \
    && locale-gen ja_JP.UTF-8 \
    && ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# setup script
# 各スクリプトは改行コード LF(UNIX) でないとエラーになる
COPY mr_scripts /mr_scripts
RUN chmod 775 mr_scripts/*
RUN /mr_scripts/install_r_packages.sh
RUN /mr_scripts/install_pandas.sh
RUN /mr_scripts/install_notocjk.sh 

USER rstudio
RUN /my_scripts/install_tinytex.sh
RUN /my_scripts/install_tex_packages.sh

# ${R_HOME}/etc/Renviron のタイムゾーン指定（Etc/UTC）を上書き
RUN echo "TZ=Asia/Tokyo" >> /home/rstudio/.Renviron

# 検証用ファイル
COPY --chown=rstudio:rstudio samples /home/rstudio/samples

USER root
ENV LANG=ja_JP.UTF-8 \
    LC_ALL=ja_JP.UTF-8 \
    TZ=Asia/Tokyo \
    PASSWORD=password \
    DISABLE_AUTH=true
    
CMD ["/init"]
