namespace :quizzes do
  desc "クイズをJSONとMarkdownでtmp/exportsに書き出す"
  task export: :environment do
    ActiveStorage::Current.url_options = { host: "http://localhost:3000" }
    count = QuizExportService.call(dir: Rails.root.join("tmp/exports"))
    puts "#{count}件のクイズを tmp/exports に書き出しました"
  end

  desc "tmp/quiz_updates/*.json の内容でクイズをまとめて更新する（DRY_RUN=1 で差分の表示だけ）"
  task apply_updates: :environment do
    dry_run = ENV["DRY_RUN"] == "1"
    lines = QuizUpdateService.call(dir: Rails.root.join("tmp/quiz_updates"), dry_run: dry_run)

    puts lines
    puts dry_run ? "DRY_RUN: #{lines.size}件の変更があります（保存していません）" : "#{lines.size}件の変更を保存しました"
  end
end
