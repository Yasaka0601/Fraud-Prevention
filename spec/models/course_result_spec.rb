require 'rails_helper'

RSpec.describe CourseResult, type: :model do
  describe '.build_from_session!' do
    # 成績を保存するユーザーと、保存先のコースを用意する。
    let!(:user) { create(:user, email: "course_result_#{SecureRandom.hex(4)}@example.com") }
    let!(:category) { Category.create!(name: '成績集計カテゴリ') }
    let!(:course) { Course.create!(category: category, name: '成績集計コース', max_questions: 2) }

    # build_from_session! が参照するクイズと選択肢を最小構成で作る。
    let!(:first_quiz_data) { create_quiz_with_choices(name: '問題1', point: 10) }
    let!(:second_quiz_data) { create_quiz_with_choices(name: '問題2', point: 20) }

    def create_quiz_with_choices(name:, point:)
      quiz = Quiz.create!(
        name: name,
        sentence: "#{name}の本文",
        explanation: "#{name}の解説",
        give_point: point
      )

      {
        quiz: quiz,
        correct_choice: Choice.create!(quiz: quiz, text: "#{name}の正解", is_correct: true),
        wrong_choice: Choice.create!(quiz: quiz, text: "#{name}の不正解", is_correct: false)
      }
    end

    def build_result_with(answers)
      # セッションに入る想定の quiz_ids / answers をそのまま渡して成績を作る。
      described_class.build_from_session!(
        user: user,
        course: course,
        quiz_ids: [first_quiz_data[:quiz].id, second_quiz_data[:quiz].id],
        answers: answers
      )
    end

    it '回答内容から成績、回答履歴、ポイントを保存すること' do
      course_result = build_result_with(
        [first_quiz_data[:correct_choice].id, second_quiz_data[:wrong_choice].id]
      )

      # 成績本体に、正解数と総問題数が保存されることを確認する。
      expect(course_result.correct_count).to eq(1)
      expect(course_result.total_questions).to eq(2)

      # 各問題の回答履歴と、選択した choice が保存されることを確認する。
      expect(course_result.quiz_histories.count).to eq(2)
      expect(course_result.quiz_histories.find_by(quiz: first_quiz_data[:quiz]).choices)
        .to contain_exactly(first_quiz_data[:correct_choice])
      expect(course_result.quiz_histories.find_by(quiz: second_quiz_data[:quiz]).choices)
        .to contain_exactly(second_quiz_data[:wrong_choice])

      # 正解した問題の分だけ、ユーザーの合計ポイントが増えることを確認する。
      expect(user.reload.total_point).to eq(10)

      # 全問正解でなくても、挑戦した記録自体は作成されることを確認する。
      challenge = UserCourseChallenge.find_by(user: user, course: course)
      expect(challenge).to be_present
      expect(challenge.conquered_at).to be_nil
    end

    it '全問正解のときは挑戦記録に conquered_at を保存すること' do
      # 先に未制覇の挑戦記録を作り、今回の成績で更新されることを確認する。
      challenge = UserCourseChallenge.create!(user: user, course: course)

      build_result_with(
        [first_quiz_data[:correct_choice].id, second_quiz_data[:correct_choice].id]
      )

      # 同じ user / course の挑戦記録を増やさず、制覇済み状態へ更新できれば十分。
      expect(UserCourseChallenge.where(user: user, course: course).count).to eq(1)
      expect(challenge.reload.conquered_at).to be_present
    end
  end
end
