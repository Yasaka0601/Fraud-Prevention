namespace :quizzes do
  desc "クイズをJSONとMarkdownでtmp/exportsに書き出す"
  task export: :environment do
    ActiveStorage::Current.url_options = { host: "http://localhost:3000" }
    count = QuizExportService.call(dir: Rails.root.join("tmp/exports"))
    puts "#{count}件のクイズを tmp/exports に書き出しました"
  end
end
