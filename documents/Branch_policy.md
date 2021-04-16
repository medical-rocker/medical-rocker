# ブランチ運用方針（暫定）

- ワークフローは基本的に git-flow に沿って運用する
    - https://www.atlassian.com/ja/git/tutorials/comparing-workflows/gitflow-workflow
- merge は極力 GitHub の pull request を使用する
- ブランチごとの `.gitignore` は使用せず、リリース版に含めない開発フォルダは **release** ブランチで削除してから pull request

最初の版のリリース前後で、再度 core team で方針を検討する。

## 主要ブランチ

- **main** \
  そのまま `docker image build` できるリリース版
- **develop** \
  開発ブランチ。作業は基本的にこのブランチとその分枝で行う
    - **feature/** \
      機能単位の開発ブランチ。以下のものを予定
        - **feature/dev_Dockerfile** : Dockerfile, docker-compose.yml とその関連ファイル
        - **feature/dev_fonts** : フォントのインストール関係
        - **feature/dev_r_packages** : R のパッケージ関係
        - **feature/dev_python** : Python の設定
        - **feature/dev_tex** : TinyTeX のインストール関係
    - **release** \
      リリース前の調整用（ドキュメント整備、開発用フォルダの削除など）

その他は、必要に応じて臨時ブランチを作成する

## 主要フォルダ・ファイル

- Dockerfile
- docker-compose.yml
- README.md
- **mr_scripts/**
    - 機能ごとのインストール用 shell スクリプトと関連ファイル
- **documents/**
    - 補助的なドキュメント（リリース時には削除予定）
    - e.g. Branch_polycy.md （このファイル） 
- **work/**
    - 開発用の作業ファイル（リリース時には削除予定）
