# About this image

- **rocker/tidyverse** を元に、医学系臨床研究で有用なパッケージを導入した作業用イメージ
- base plot, ggplot2 によるグラフ描画や Rmarkdown による PDF 出力を含めた日本語設定を行う
- `reticulate` で最低限の python 連携も使用できるようにする
- [rocker-org/rocker-versioned2](https://github.com/rocker-org/rocker-versioned2) のように、目的別のスクリプトを使って Dockerfile 自体は極力シンプルにしてみる

## How to use

このレポジトリを clone あるいは、全てのファイル・フォルダを（ZIPなどで）ダウンロードし、`Dockerfile` と `docker-compose.yml` のある階層で以下を実行する

### docker-compose がある場合

```
# イメージ medical-rocker/tidyverse_ja:4.0.4 を作成（成功時 4.64 GB）
docker-compose build
# イメージ medical-rocker/tidyverse_ja:4.0.4_full を作成（成功時 6.4 GB）
docker-compose -f docker-compose_full.yml build

# コンテナ rstudio として起動
# 通常版 medical-rocker/tidyverse_ja:4.0.4
docker-compose up -d
# 拡張版 medical-rocker/tidyverse_ja:4.0.4_full
docker-compose -f docker-compose_full.yml up -d

# http://localhost:8787 に接続して利用（パスワード不要）

# コンテナの終了、削除
docker-compose down
```

### docker-compose がない場合

```
# イメージ medical-rocker/tidyverse_ja:4.0.4 を作成（成功時 4.64 GB）
docker image build -t "medical-rocker/tidyverse_ja:4.0.4" .
# イメージ medical-rocker/tidyverse_ja:4.0.4_full を作成（成功時 6.4 GB）
docker image build -t "medical-rocker/tidyverse_ja:4.0.4" -f Dockerfile_full .

# コンテナ rstudio として起動
# 通常版 medical-rocker/tidyverse_ja:4.0.4
docker run --rm -d -p 8787:8787 --name rstudio medical-rocker/tidyverse_ja:4.0.4
# 拡張版 medical-rocker/tidyverse_ja:4.0.4_full
docker run --rm -d -p 8787:8787 --name rstudio medical-rocker/tidyverse_ja:4.0.4_full

# http://localhost:8787 に接続して利用（パスワード不要）

# コンテナの終了、削除
docker stop rstudio
```


## 詳細／暫定方針

### Ubuntu mirror

- 自動選択の `mirror://mirrors.ubuntu.com/mirrors.txt` に変更
- Ref: https://blog.amedama.jp/entry/2019/09/11/234050

### 日本語設定

- Ubuntu の `language-pack-ja`, `language-pack-ja-base`
- 環境変数で `ja_JP.UTF-8` ロケールとタイムゾーン `Asia/Tokyo` を指定
- フォントは Noto Sans/Serif CJK JP
    - Ubuntu の `fonts-noto-cjk` パッケージのみでは XeLaTeX + BXjscls で日本語PDFを作成する際に不足するウェイトがある
    - それらを含む、`fonts-noto-cjk-extra` は KR, SC, TC のフォントを含む巨大なパッケージ
    - 容量節約のため、[Google Noto Fonts](https://www.google.com/get/noto/) から OTF 版をダウンロードして JP の必要なウェイトのみを手動でインストールする

### Python

- rocker project で用意されている `/rocker_scripts/install_python.sh` を利用してインストール
- `Pandas` と `Seaborn` (`matplotlib`) も入れておく（とりあえず、仮想環境は作らず sytem wide に）

### TinyTeX

- XeLaTeX + BXjscls で日本語PDFを作成するのに必要なパッケージも予めインストールしておく
- 2021年3月末で TeX Live 2020 が更新終了（frozen）となったので、日本語 TeX 開発コミュニティ texjp.org のサーバにあるTeX Live 2020 のアーカイブを利用するようにする
- TinyTeX はそれに合わせて "2021.03" をインストールする

### R の頻用パッケージ

- Causal Inference Slack で募集されたものを追加
- https://docs.google.com/spreadsheets/d/175Q_lzNG7P6TT2k9rUzzweoaKdJS_OJZ3lWpUuTfcvc/edit#gid=0
- 容量節約のため、インストール後にDLしたアーカイブは削除する

### 環境変数 PASSWORD の仮設定

- Docker Desktop など `-e PASSWORD=...` が設定できないGUIでも起動テストできるように仮のパスワード（password）を埋め込んでおく
- 更に、普段使いのため `DISABLE_AUTH=true` を埋め込む。パスワードが必要なときは、起動時に `-e DISABLE_AUTH=false`

## History

- 2021-05-06 :bookmark: [4.0.4_alpha01](https://github.com/medical-rocker/medical-rocker/releases/tag/4.0.4_alpha01) 最初の開発版
- 2021-05-09 :octocat: medical-rocker/medical-rocker に移管
