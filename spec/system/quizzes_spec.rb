require 'rails_helper'

RSpec.describe "Quizzes", type: :system do
  # クイズ一覧の親データ（カテゴリー・コース）をテスト用に作成する。
  let!(:category) { Category.create!(name: 'カテゴリー テスト') }
  let!(:course) { Course.create!(category: category, name: 'コース テスト', max_questions: 5) }

  # クイズ5問と選択肢を作成し、カテゴリー/コースへ紐付ける。
  let!(:quizzes) do
    5.times.map do |i|
      quiz = Quiz.create!(
        name: "Quiz #{i + 1}",
        sentence: "テスト問題 #{i + 1}",
        explanation: "テスト解説 #{i + 1}",
        give_point: 10
      )

      QuizCategory.create!(quiz: quiz, category: category)
      CourseQuiz.create!(course: course, quiz: quiz)

      Choice.create!(quiz: quiz, text: "Q#{i + 1} 正解", is_correct: true)
      Choice.create!(quiz: quiz, text: "Q#{i + 1} 不正解", is_correct: false)
      quiz
    end
  end

  # 回答パターン（完成版）：正解3問・不正解2問の混在ケース。
  let!(:answer_choice_texts) do
    [
      'Q1 正解',
      'Q2 不正解',
      'Q3 正解',
      'Q4 不正解',
      'Q5 正解'
    ]
  end
  # 回答配列に基づく期待正解数（回答内容を変えても追従する）。
  let!(:expected_correct_count) do
    answer_choice_texts.each_with_index.count do |choice_text, idx|
      quizzes[idx].choices.find_by(text: choice_text)&.is_correct
    end
  end
  let!(:expected_total_point) { expected_correct_count * 10 }

  before do
    # 出題順を固定化するため、RANDOM() の代わりに作成順のIDを返すようスタブする。
    fixed_quiz_ids = quizzes.map(&:id)
    allow_any_instance_of(Course).to receive_message_chain(:quizzes, :order, :pluck).and_return(fixed_quiz_ids)
  end

  # コース一覧からクイズを開始する共通処理（POST の start アクションを経由する）。
  def start_quiz
    visit category_courses_path(category)
    find('button.course-card').click
  end

  # 5問回答して結果リンク表示まで進める共通処理。
  def answer_all_questions(answer_texts)
    answer_texts.each_with_index do |choice_text, i|
      # 何問目かと問題文が固定順で表示されることを確認する。
      expect(page).to have_content("第 #{i + 1} 問")
      expect(page).to have_content("テスト問題 #{i + 1}")

      # 1問分回答する（回答内容は answer_choice_texts で調整可能）。
      choose choice_text
      click_button '回答する'

      if i < 4
        # 1〜4問目は「次の問題へ進む」リンクで次へ遷移する。
        expect(page).to have_link('次の問題へ進む')
        click_link '次の問題へ進む'
      else
        # 5問目は結果リンクが表示される。
        expect(page).to have_link('結果を確認する')
      end
    end
  end

  describe 'ゲストでのクイズ挑戦' do
    it '固定順で5問出題され、ゲスト結果画面まで進めること' do
      start_quiz
      answer_all_questions(answer_choice_texts)
      click_link '結果を確認する'

      # ゲスト結果画面へ遷移し、結果ヘッダーが表示されることを確認する。
      expect(page).to have_current_path(guest_result_course_quiz_index_path(course))
      expect(page).to have_content('稽古結果')
      expect(page).to have_content('正解数')
      expect(page).to have_content("#{expected_correct_count} / 5 問")
    end
  end

  describe 'ログインユーザーでのクイズ挑戦' do
    # ログインして成績保存されることを確認するためのユーザー。
    let!(:user) { create(:user, email: "quiz_user_#{SecureRandom.hex(4)}@example.com") }

    before do
      login_as_user(user)
    end

    it '固定順で5問回答し、成績詳細画面で結果を確認できること' do
      start_quiz
      answer_all_questions(answer_choice_texts)
      click_link '結果を確認する'

      # ログイン時は成績詳細画面へ遷移し、保存された結果が見える。
      expect(page).to have_current_path(%r{\A/results/\d+\z})
      expect(page).to have_content(course.name)
      expect(page).to have_content('正解数')
      expect(page).to have_content("#{expected_correct_count} / 5 問")

      # 成績が1件保存され、ユーザーのポイントが加算されることを確認する。
      expect(CourseResult.where(user: user, course: course).count).to eq(1)
      expect(user.reload.total_point).to eq(expected_total_point)
    end
  end
end
