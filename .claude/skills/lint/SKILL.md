---
name: lint
description: RuboCopでLintチェックを実行し、オフェンス一覧を報告する。要望があれば自動修正も行う。
---

# Lint実行

ローカルにRuby実行環境が入っていないため、`compose.yml`の`web`コンテナ内で実行する。

まず `docker compose ps` でコンテナが起動しているか確認し、起動していなければユーザーに起動を依頼する。

`docker compose exec web bundle exec rubocop` を実行し、結果を報告する。

- オフェンスがあれば、ファイル・行番号・違反ルールを簡潔にまとめて報告する
- 自動修正してよいかユーザーに確認し、了承があれば `docker compose exec web bundle exec rubocop -a`（安全な自動修正のみ）を実行する
- `-a` で直らないオフェンスが残る場合、`-A`（安全でない自動修正も含む）を使うかどうか改めてユーザーに確認する
- 全て問題なければその旨だけ簡潔に報告する
