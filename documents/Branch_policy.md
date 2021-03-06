# ブランチ運用方針（暫定）

基本的に、[Organizationのルール](https://github.com/medical-rocker/docs/blob/main/github_rules.md) に沿って運用する。

このレポジトリ medical-rocker/medical-rocker での方針として、

- ワークフローは基本的に git-flow に沿って運用する
    - https://www.atlassian.com/ja/git/tutorials/comparing-workflows/gitflow-workflow
- merge は極力 GitHub の pull request を使用する
- ブランチごとの `.gitignore` は使用せず、リリース版に含めないファイルダは **release** ブランチで削除してから pull request


## 主要ブランチ

- **main** \
  そのまま `docker image build` できるリリース版
- **develop** \
  開発ブランチ。作業は基本的にこのブランチとその分枝で行う
    - **feature/** \
      機能単位の開発ブランチ。以下のものを予定
        - **feature/dev_Dockerfile** : Dockerfile, docker-compose.yml とその関連ファイル
        - **feature/dev_r_packages** : R のパッケージ関係
        - **feature/dev_fonts** : フォントのインストール関係
        - **feature/dev_python** : Python の設定
        - **feature/dev_tex** : TinyTeX のインストール関係
        - **feature/dev_samples** : イメージに含める動作確認用サンプルファイルなど
    - **release** \
      リリース前の調整用（ドキュメント整備、開発用一時ファイルの削除など）

その他は、必要に応じて臨時ブランチを作成する

## 主要フォルダ・ファイル（レポジトリ内）

- .gitignore
- .dockerignore
- Dockerfile*
- docker-compose*.yml
- README.md
- **mr_scripts/**
    - 機能ごとのインストール用 shell スクリプトと関連ファイル
    - イメージ作成時にイメージ内 `/mr_scripts/` に COPY して利用
- **samples/**
    - 動作確認用サンプルファイルなど
    - イメージ作成時にイメージ内 `/home/rstudio/samples/` に COPY
- **documents/**
    - 補助的なドキュメント
    - e.g. Branch_polycy.md （このファイル） 
