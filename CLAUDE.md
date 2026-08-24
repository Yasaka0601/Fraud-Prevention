# 詐欺対策道場

家族で詐欺クイズに挑戦し、防犯知識を学べるRailsアプリ。
クイズ機能と、家族ルームで成績を共有する機能が中心。

## 技術スタック

- Ruby 3.3.6 / Rails 7.2.3.2 / Bundler 2.7.2
- DB: PostgreSQL 17（本番はNeon、デプロイ先はRender）
- 認証: Devise + devise-i18n、OmniAuth（LINE, Google OAuth2）
- 認可: CanCanCan / 管理画面: RailsAdmin
- フロント: Hotwire（Turbo + Stimulus）+ Tailwind CSS v4 + daisyUI（esbuild + cssbundling-rails）。React/Vue等は無し
- 画像: Cloudinary + ActiveStorage
- テスト: RSpec + FactoryBot + Capybara/Selenium（system spec）
- Lint/セキュリティ: rubocop-rails-omakase（カスタム設定なし）、Brakeman
- ローカル環境: `compose.yml`によるDocker構成

## よく使うコマンド

ローカルにRuby実行環境が入っていないため、`bundle`/`rails`系コマンドは`docker compose exec web`経由で実行する（CIはGitHub Actions上でRubyをセットアップして直接実行）。

```
docker compose up                                # ローカル開発環境起動
docker compose exec web bundle exec rspec              # 全テスト実行
docker compose exec web bundle exec rspec spec/models  # 特定ディレクトリ/ファイルのみ
docker compose exec web bundle exec rubocop             # Lintチェック
docker compose exec web bundle exec rubocop -a          # 自動修正（安全なもののみ）
docker compose exec web bin/rails db:prepare            # DBセットアップ
```

## ディレクトリ構成の要点

- `app/services/` — カスタムサービスオブジェクト
- `app/javascript/controllers/` — Stimulusコントローラー
- `spec/` — テスト本体（RSpec）。`test/`ディレクトリは未使用の残骸なので触らなくてよい

## CI（`.github/workflows/ci.yml`）

- `rubocop`ジョブ
- `rspec`ジョブ（Postgres 17を起動し `bin/rails db:prepare && bundle exec rspec`）

## 機密情報（絶対に読み書き・出力しない）

- `.env`（`MAILER_SENDER`, `MAILER_PASSWORD`, `LINE_KEY`, `LINE_SECRET`, `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET`）
- `config/master.key`
- `config/credentials.yml.enc`（編集・上書き禁止。暗号化済みなのでコミット自体は正常）

これらは`.claude/settings.json`でツールアクセスを制限済み。値を推測したり、内容を出力したりしない。
