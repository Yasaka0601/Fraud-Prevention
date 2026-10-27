# Neon からの書き出し手順（ユーザー向け）

本番DB（Neon）のクイズを、自分のPCに書き出すための手順です。

## 最初に知っておくこと
- **パスワードや接続文字列は、Claude との会話に貼らない**
  - ターミナルの出力を貼るときも、パスワードが含まれていないか確認する
  - もし貼ってしまったら、「A. パスワードを作り直す」をやる
- Rails のエラーには接続文字列がそのまま表示されます。エラーを Claude に伝えるときは、**1行目だけ**を、`postgresql://` から後ろを消して貼る
  ```
  URI::InvalidURIError: bad URI (is not URI?): （ここから後ろは消す）
  ```
- 書き出しの前に Docker Desktop を起動し、`docker compose up` しておく

---

## 0. 初回だけ：読み取り専用ユーザーを作る
すでに `quiz_reader` を作ってある場合は不要です（2026年10月に作成済み）。

1. https://console.neon.tech にログインし、プロジェクト **Fraud_Prevention** を開く
2. 画面左上が **Fraud_Prevention / production** になっていることを確認する（ブランチ名の横に「Default」の印）
3. 左メニューの **Postgres database** の下にある **SQL Editor** を開く
4. 入力欄の上にあるプルダウンを確認する
   - 左：**Primary**（Active）→ そのままでOK
   - 右：**neondb** → これがデータベース名
5. **入力欄に最初から入っているサンプルのSQLを全部消す**（`command + A` → `delete`）
   - ⚠️ サンプルのまま Run すると、本番DBに練習用のテーブルが作られてしまう
6. ターミナルでパスワードを作る（画面には出ず、クリップボードにコピーされる）
   ```
   openssl rand -hex 16 | tr -d '\n' | pbcopy
   ```
7. SQL Editor に次を貼り付け、パスワードの部分で `command + V` してから **Run**
   ```sql
   CREATE ROLE quiz_reader WITH LOGIN PASSWORD 'ここに貼り付け';
   GRANT CONNECT ON DATABASE neondb TO quiz_reader;
   GRANT USAGE ON SCHEMA public TO quiz_reader;
   GRANT SELECT ON quizzes, choices, categories, quiz_categories, courses, course_quizzes,
     active_storage_attachments, active_storage_blobs TO quiz_reader;
   ```
   - `role "quiz_reader" already exists` と出たら、すでに作ってあるということ。「A」へ進む
8. パスワードはメモアプリなど自分だけが見られる場所に保存しておく（Claude には伝えない）

---

## A. パスワードを作り直す（忘れたとき・会話に貼ってしまったとき）
前のパスワードは不要です。新しいもので上書きします。

1. ターミナルで実行（画面には出ず、クリップボードにコピーされる）
   ```
   openssl rand -hex 16 | tr -d '\n' | pbcopy
   ```
2. Neon の **SQL Editor** を開き、**入力欄を全部消してから**次を貼り付ける。パスワードの部分で `command + V` して **Run**
   ```sql
   ALTER ROLE quiz_reader WITH PASSWORD 'ここに貼り付け';
   ```
3. エラーが出なければOK。新しいパスワードを自分だけが見られる場所に保存しておく

---

## B. 接続文字列を用意する
1. Neon のプロジェクト画面で、左上の緑の **Connect** ボタンを押す
2. 接続文字列が表示されるので、メモアプリなどに貼り付ける
   ```
   postgresql://neondb_owner:********@ep-xxxx-pooler.ap-southeast-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require
   ```
   - 先頭に `psql '` が付いた形でもOK（次の C で自動的に取り除く）
3. `://` と `:` の間（ユーザー名）を `quiz_reader` に書き換える
4. `quiz_reader:` と `@` の間（パスワード）を消して、`quiz_reader` のパスワードを貼る
   ```
   postgresql://quiz_reader:（パスワード）@ep-xxxx-pooler.ap-southeast-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require
   ```
   - `@` から後ろは1文字も変えない
5. 全体をコピーする

---

## C. ターミナルで書き出す
プロジェクトのフォルダで、**同じターミナルのまま**順番に実行します。

1. 接続文字列を読み込む
   ```
   read -s NEON_URL
   ```
   - Enter を押すと入力待ちになる。B でコピーした文字列を貼り付けて、もう一度 Enter
   - **画面には何も表示されないが、入力はされている**
   - `read -s NEON_URL 接続文字列` のように1行で書かない（画面と履歴に残ってしまう）

2. `psql '` を取り除き、形が正しいか確認する
   ```
   NEON_URL=$(printf %s "$NEON_URL" | sed -E "s/^psql '//; s/'$//")
   case "$NEON_URL" in postgresql://*) echo "OK";; *) echo "NG";; esac
   ```
   - `OK` → 次へ
   - `NG` → 1 からやり直す

3. 書き出す
   ```
   docker compose exec -e DATABASE_URL="$NEON_URL" web bin/rails quizzes:export
   ```
   - `〇件のクイズを tmp/exports に書き出しました` と出たら成功
   - `-e DATABASE_URL=...` は「このコマンドの間だけ接続先を Neon にする」という意味。ローカルの設定は変わらない

4. **ターミナルを閉じる**（`NEON_URL` が消える）

5. Claude に「〇件でした」と伝える

---

## よくあるエラー
| 表示 | 原因と対処 |
|---|---|
| `URI::InvalidURIError` | 接続文字列の形が違う。C-2 で `OK` が出るか確認する |
| `password authentication failed` | パスワードが違う。A で作り直して B からやり直す |
| `permission denied for table ...` | `quiz_reader` に読む権限がないテーブルがある。SQL Editor で `GRANT SELECT ON テーブル名 TO quiz_reader;` |
| `Cannot connect to the Docker daemon` | Docker Desktop が起動していない |
| `could not translate host name` | 接続文字列が途中で切れている。B からやり直す |
