require 'rails_helper'

RSpec.describe "SharedQuizzes", type: :system do
  let!(:quiz) do
    Quiz.create!(
      name: 'テストクイズ',
      sentence: 'これはテスト問題です',
      explanation: 'これはテスト解説です',
      give_point: 10
    )
  end
  let!(:correct_choice) { Choice.create!(quiz: quiz, text: '正しい選択肢', is_correct: true) }
  let!(:wrong_choice)   { Choice.create!(quiz: quiz, text: '誤った選択肢', is_correct: false) }

  describe '未ログインでのクイズ挑戦' do
    it '問題が表示され、正解を選ぶと正誤判定と解説が表示されること' do
      visit share_quiz_path(quiz)

      expect(page).to have_content(quiz.sentence)

      choose correct_choice.text
      click_button '回答する'

      expect(page).to have_content('見事！正解')
      expect(page).to have_content(quiz.explanation)
      expect(page).to have_link('他のクイズに挑戦', href: home_path)
    end

    it '不正解を選ぶと不正解の判定が表示されること' do
      visit share_quiz_path(quiz)

      choose wrong_choice.text
      click_button '回答する'

      expect(page).to have_content('無念...不正解')
      expect(page).to have_content(correct_choice.text)
    end
  end
end
