require 'rails_helper'

RSpec.describe QuizUpdateService do
  let!(:quiz) do
    Quiz.create!(name: "還付金の電話", sentence: "市役所から還付金の電話が来た。どうする？",
                 explanation: "ATMで還付金は受け取れません。", give_point: 10)
  end
  let!(:correct_choice) { quiz.choices.create!(text: "電話を切って市役所に確認する", is_correct: true) }
  let!(:wrong_choice)   { quiz.choices.create!(text: "ATMに向かう", is_correct: false) }

  around do |example|
    Dir.mktmpdir do |dir|
      @dir = Pathname(dir)
      example.run
    end
  end

  def write_updates(quizzes, filename: "01.json")
    File.write(@dir.join(filename), { quizzes: quizzes }.to_json)
  end

  let(:new_choices) do
    [
      { id: correct_choice.id, text: "ATMに向かう", is_correct: false },
      { id: wrong_choice.id, text: "電話を切って市役所に確認する", is_correct: true }
    ]
  end

  describe '.call' do
    it 'クイズと選択肢を更新する' do
      write_updates([ { id: quiz.id, explanation: "新しい解説", give_point: 3, choices: new_choices } ])

      QuizUpdateService.call(dir: @dir)

      expect(quiz.reload).to have_attributes(explanation: "新しい解説", give_point: 3, name: "還付金の電話")
      expect(correct_choice.reload).to have_attributes(text: "ATMに向かう", is_correct: false)
      expect(wrong_choice.reload).to have_attributes(text: "電話を切って市役所に確認する", is_correct: true)
    end

    it '変わる項目だけを差分として返す' do
      write_updates([ { id: quiz.id, name: "還付金の電話", give_point: 3 } ])

      lines = QuizUpdateService.call(dir: @dir)

      expect(lines).to eq([ "クイズID #{quiz.id} give_point\n  今: 10\n  新: 3" ])
    end

    it 'DRY_RUN のときは差分を返すだけで保存しない' do
      write_updates([ { id: quiz.id, give_point: 3, choices: new_choices } ])

      lines = QuizUpdateService.call(dir: @dir, dry_run: true)

      expect(lines.size).to eq(5)
      expect(quiz.reload.give_point).to eq(10)
      expect(correct_choice.reload.is_correct).to be(true)
    end

    it '複数のファイルをまとめて読み込む' do
      other_quiz = Quiz.create!(name: "別のクイズ", sentence: "問題文", give_point: 1)
      other_quiz.choices.create!(text: "正解", is_correct: true)
      write_updates([ { id: quiz.id, give_point: 3 } ], filename: "01.json")
      write_updates([ { id: other_quiz.id, give_point: 5 } ], filename: "02.json")

      QuizUpdateService.call(dir: @dir)

      expect(quiz.reload.give_point).to eq(3)
      expect(other_quiz.reload.give_point).to eq(5)
    end

    context 'チェックに引っかかるとき' do
      it '選択肢のIDが本番と一致しなければ、何も更新しない' do
        write_updates([ { id: quiz.id, give_point: 3, choices: [ new_choices.first ] } ])

        expect { QuizUpdateService.call(dir: @dir) }.to raise_error(ArgumentError, /選択肢のIDが本番と一致しません/)
        expect(quiz.reload.give_point).to eq(10)
      end

      it '本番にないクイズIDはエラーにする' do
        write_updates([ { id: 0, give_point: 3 } ])

        expect { QuizUpdateService.call(dir: @dir) }.to raise_error(ArgumentError, /本番にありません/)
      end

      it '同じクイズIDが2回あればエラーにする' do
        write_updates([ { id: quiz.id, give_point: 3 }, { id: quiz.id, give_point: 4 } ])

        expect { QuizUpdateService.call(dir: @dir) }.to raise_error(ArgumentError, /同じクイズIDが2回以上あります/)
      end

      it '知らない項目があればエラーにする' do
        write_updates([ { id: quiz.id, explantion: "打ち間違い" } ])

        expect { QuizUpdateService.call(dir: @dir) }.to raise_error(ArgumentError, /知らない項目があります: explantion/)
      end

      it '正解の選択肢がなければエラーにする' do
        choices = new_choices.map { |choice| choice.merge(is_correct: false) }
        write_updates([ { id: quiz.id, choices: choices } ])

        expect { QuizUpdateService.call(dir: @dir) }.to raise_error(ArgumentError, /正解の選択肢がありません/)
      end

      it '「（複数回答可能です）」があるのに正解が1つならエラーにする' do
        write_updates([ { id: quiz.id, sentence: "どれ？（複数回答可能です）" } ])

        expect { QuizUpdateService.call(dir: @dir) }.to raise_error(ArgumentError, /正解が1つです/)
      end

      it '正解が複数なのに「（複数回答可能です）」がなければエラーにする' do
        choices = new_choices.map { |choice| choice.merge(is_correct: true) }
        write_updates([ { id: quiz.id, choices: choices } ])

        expect { QuizUpdateService.call(dir: @dir) }.to raise_error(ArgumentError, /がありません/)
      end
    end

    it 'バリデーションに引っかかれば、先に更新したクイズも元に戻す' do
      other_quiz = Quiz.create!(name: "別のクイズ", sentence: "問題文", give_point: 1)
      other_quiz.choices.create!(text: "正解", is_correct: true)
      write_updates([ { id: quiz.id, give_point: 3 }, { id: other_quiz.id, name: "あ" * 51 } ])

      expect { QuizUpdateService.call(dir: @dir) }.to raise_error(ActiveRecord::RecordInvalid)
      expect(quiz.reload.give_point).to eq(10)
    end
  end
end
