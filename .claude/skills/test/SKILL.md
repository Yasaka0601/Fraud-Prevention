---
name: test
description: RSpecでテストを実行し、失敗内容を要約する。引数でファイル/ディレクトリを指定可能。
---

# テスト実行

ローカルにRuby実行環境が入っていないため、`compose.yml`の`web`コンテナ内で実行する。

まず `docker compose ps` でコンテナが起動しているか確認し、起動していなければユーザーに起動を依頼する。

`docker compose exec web bundle exec rspec` を実行し、結果を報告する。

- 引数が指定されていれば `docker compose exec web bundle exec rspec <引数>` のように対象を絞る（例: `spec/models/quiz_spec.rb`）
- 引数がなければ全テストを実行する
- 失敗があれば、失敗したテスト名・ファイル・行番号・エラーメッセージを簡潔にまとめて報告する
- 全て成功した場合は成功件数のみ簡潔に報告する
- テストコード自体の修正は行わない（ユーザーの依頼があれば別途対応する）
