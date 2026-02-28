require 'rails_helper'

RSpec.describe "Results", type: :system do
  # 成績を閲覧するログインユーザー。
  let!(:user) { create(:user, email: "results_user_#{SecureRandom.hex(4)}@example.com") }
  # 成績に紐づく最小限のカテゴリ・コース。
  let!(:category) { Category.create!(name: '成績カテゴリ') }
  let!(:course) { Course.create!(category: category, name: '成績コース', max_questions: 2) }
  # 一覧と詳細で表示する成績本体。今回は 2 問中 1 問正解のケースを作る。
  let!(:course_result) do
    CourseResult.create!(
      user: user,
      course: course,
      correct_count: 1,
      total_questions: 2,
      finished_at: Time.current
    )
  end

  # 詳細画面で振り返り表示を出すための問題データ。
  let!(:first_quiz) do
    Quiz.create!(
      name: '成績問題1',
      sentence: '成績機能の問題1',
      explanation: '成績機能の解説1',
      give_point: 10
    )
  end
  let!(:second_quiz) do
    Quiz.create!(
      name: '成績問題2',
      sentence: '成績機能の問題2',
      explanation: '成績機能の解説2',
      give_point: 10
    )
  end
  # 1 問目は正解、2 問目は不正解になるように回答履歴を組み立てる。
  let!(:first_correct_choice) { Choice.create!(quiz: first_quiz, text: '問題1の正解', is_correct: true) }
  let!(:first_wrong_choice) { Choice.create!(quiz: first_quiz, text: '問題1の不正解', is_correct: false) }
  let!(:second_correct_choice) { Choice.create!(quiz: second_quiz, text: '問題2の正解', is_correct: true) }
  let!(:second_wrong_choice) { Choice.create!(quiz: second_quiz, text: '問題2の不正解', is_correct: false) }

  # course_result にぶら下がる各問題の回答履歴。
  let!(:first_history) { QuizHistory.create!(user: user, course_result: course_result, quiz: first_quiz) }
  let!(:second_history) { QuizHistory.create!(user: user, course_result: course_result, quiz: second_quiz) }

  let!(:first_history_choice) { QuizHistoryChoice.create!(quiz_history: first_history, choice: first_correct_choice) }
  let!(:second_history_choice) { QuizHistoryChoice.create!(quiz_history: second_history, choice: second_wrong_choice) }

  before do
    # 成績画面は認証必須のため、毎回ログインしてから開始する。
    login_as_user(user)
  end

  describe '成績一覧' do
    it '保存済みの成績を確認できること' do
      visit results_path

      # 一覧に成績タイトルとスコアが表示されることを確認する。
      expect(page).to have_content('稽古の記録')
      expect(page).to have_content(course.name)
      expect(page).to have_css('.history-score-badge', text: '1 / 2')

      # 一覧から詳細へ遷移できれば、最低限の導線確認として十分。
      click_link course.name

      expect(page).to have_current_path(result_path(course_result))
    end
  end

  describe '成績詳細' do
    it '正解数と獲得ポイントを確認できること' do
      visit result_path(course_result)

      # ヘッダーの集計表示と、各問題の振り返り内容を確認する。
      expect(page).to have_content(course.name)
      expect(page).to have_content('正解数')
      expect(page).to have_content('1 / 2 問')
      expect(page).to have_css('.result-point-badge', text: '10')
      expect(page).to have_content('成績機能の問題1')
      expect(page).to have_content('問題1の正解')
      expect(page).to have_content('成績機能の問題2')
      expect(page).to have_content('問題2の不正解')
    end
  end
end
