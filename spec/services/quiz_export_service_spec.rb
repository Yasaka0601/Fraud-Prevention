require 'rails_helper'

RSpec.describe QuizExportService do
  let!(:category) { Category.create!(name: "還付金詐欺") }
  let!(:quiz) do
    Quiz.create!(name: "還付金の電話", sentence: "市役所から還付金の電話が来た。どうする？",
                 explanation: "ATMで還付金は受け取れません。", give_point: 10, categories: [ category ])
  end
  let!(:correct_choice) { quiz.choices.create!(text: "電話を切って市役所に確認する", is_correct: true) }
  let!(:wrong_choice)   { quiz.choices.create!(text: "ATMに向かう", is_correct: false) }

  around do |example|
    Dir.mktmpdir do |dir|
      @dir = Pathname(dir)
      example.run
    end
  end

  describe '.call' do
    it '書き出した件数を返す' do
      expect(QuizExportService.call(dir: @dir)).to eq(1)
    end

    it 'JSONにクイズ・選択肢・カテゴリが含まれる' do
      QuizExportService.call(dir: @dir)
      json = JSON.parse(@dir.join("quizzes.json").read)
      exported = json["quizzes"].first

      expect(json["count"]).to eq(1)
      expect(exported["name"]).to eq("還付金の電話")
      expect(exported["categories"]).to eq([ "還付金詐欺" ])
      expect(exported["choices"]).to eq([
        { "text" => "電話を切って市役所に確認する", "is_correct" => true },
        { "text" => "ATMに向かう", "is_correct" => false }
      ])
    end

    it 'Markdownに問題文と正解マークが含まれる' do
      QuizExportService.call(dir: @dir)
      markdown = @dir.join("quizzes.md").read

      expect(markdown).to include("市役所から還付金の電話が来た。どうする？")
      expect(markdown).to include("✅ 電話を切って市役所に確認する")
    end
  end
end
