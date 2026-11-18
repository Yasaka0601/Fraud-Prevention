require 'rails_helper'

RSpec.describe QuizImportService do
  let!(:web) { Category.create!(name: "WEB") }
  let!(:sns) { Category.create!(name: "SNS") }
  let!(:existing_quiz) do
    Quiz.create!(name: "本番にあるクイズ", sentence: "問題文", give_point: 4).tap do |quiz|
      quiz.choices.create!(text: "正解", is_correct: true)
    end
  end

  around do |example|
    Dir.mktmpdir do |dir|
      @dir = Pathname(dir)
      example.run
    end
  end

  def write_imports(quizzes: [], courses: [], filename: "01.json")
    File.write(@dir.join(filename), { quizzes: quizzes, courses: courses }.to_json)
  end

  let(:new_quiz) do
    {
      key: "vpn-1", name: "VPNとは？", sentence: "VPNの説明として正しいものは？",
      explanation: "VPNは通信を暗号化する仕組みです。", give_point: 3, categories: [ "WEB", "SNS" ],
      choices: [ { text: "通信を暗号化する", is_correct: true }, { text: "ウイルスを消す", is_correct: false } ]
    }
  end
  let(:new_course) { { name: "公衆Wi-FiとVPN", category: "WEB", max_questions: 5, quizzes: [ "vpn-1", existing_quiz.id ] } }

  describe '.call' do
    it 'クイズ・選択肢・カテゴリ・コースを登録する' do
      write_imports(quizzes: [ new_quiz ], courses: [ new_course ])

      expect { QuizImportService.call(dir: @dir) }
        .to change(Quiz, :count).by(1).and change(Choice, :count).by(2).and change(Course, :count).by(1)

      quiz = Quiz.find_by!(name: "VPNとは？")
      expect(quiz).to have_attributes(explanation: "VPNは通信を暗号化する仕組みです。", give_point: 3)
      expect(quiz.categories).to contain_exactly(web, sns)
      expect(quiz.choices.order(:id).map { |choice| [ choice.text, choice.is_correct ] })
        .to eq([ [ "通信を暗号化する", true ], [ "ウイルスを消す", false ] ])

      course = Course.find_by!(name: "公衆Wi-FiとVPN")
      expect(course).to have_attributes(category: web, max_questions: 5)
      expect(course.quizzes).to contain_exactly(quiz, existing_quiz)
    end

    it '新しいクイズのkeyとIDを返す' do
      write_imports(quizzes: [ new_quiz ])

      lines = QuizImportService.call(dir: @dir)

      expect(lines).to eq([ "クイズ vpn-1 → ID #{Quiz.last.id}「VPNとは？」" ])
    end

    it 'DRY_RUN のときは1件も保存しない' do
      write_imports(quizzes: [ new_quiz ], courses: [ new_course ])

      lines = QuizImportService.call(dir: @dir, dry_run: true)

      expect(lines.size).to eq(2)
      expect(Quiz.count).to eq(1)
      expect(Choice.count).to eq(1)
      expect(Course.count).to eq(0)
    end

    it 'DRY_RUN のあとに登録しても、IDの番号が飛ばない' do
      write_imports(quizzes: [ new_quiz ], courses: [ new_course ])

      QuizImportService.call(dir: @dir, dry_run: true)
      QuizImportService.call(dir: @dir)

      expect(Quiz.find_by!(name: "VPNとは？").id).to eq(existing_quiz.id + 1)
    end

    it 'DRY_RUN でもバリデーションに引っかかればエラーにする' do
      write_imports(quizzes: [ new_quiz.merge(name: "あ" * 51) ])

      expect { QuizImportService.call(dir: @dir, dry_run: true) }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it '複数のファイルをまとめて読み込む' do
      write_imports(quizzes: [ new_quiz ], filename: "01.json")
      write_imports(courses: [ new_course ], filename: "02.json")

      expect { QuizImportService.call(dir: @dir) }.to change(Course, :count).by(1)
    end

    context 'チェックに引っかかるとき' do
      it '1件も保存しない' do
        write_imports(quizzes: [ new_quiz, new_quiz.merge(key: "vpn-2", choices: []) ])

        expect { QuizImportService.call(dir: @dir) }.to raise_error(ArgumentError, /vpn-2: 選択肢が2つ未満です/)
        expect(Quiz.count).to eq(1)
      end

      it '同じkeyが2回あればエラーにする' do
        write_imports(quizzes: [ new_quiz, new_quiz ])

        expect { QuizImportService.call(dir: @dir) }.to raise_error(ArgumentError, /同じkeyが2回以上あります: vpn-1/)
      end

      it '本番にないカテゴリはエラーにする' do
        write_imports(quizzes: [ new_quiz.merge(categories: [ "メール" ]) ])

        expect { QuizImportService.call(dir: @dir) }.to raise_error(ArgumentError, /本番にないカテゴリです: メール/)
      end

      it '正解の選択肢がなければエラーにする' do
        choices = new_quiz[:choices].map { |choice| choice.merge(is_correct: false) }
        write_imports(quizzes: [ new_quiz.merge(choices: choices) ])

        expect { QuizImportService.call(dir: @dir) }.to raise_error(ArgumentError, /正解の選択肢がありません/)
      end

      it '知らない項目があればエラーにする' do
        write_imports(quizzes: [ new_quiz.merge(explantion: "打ち間違い") ])

        expect { QuizImportService.call(dir: @dir) }.to raise_error(ArgumentError, /知らない項目があります: explantion/)
      end

      it '同じ名前のコースが本番にあればエラーにする' do
        Course.create!(name: "公衆Wi-FiとVPN", category: web, max_questions: 5)
        write_imports(quizzes: [ new_quiz ], courses: [ new_course ])

        expect { QuizImportService.call(dir: @dir) }.to raise_error(ArgumentError, /同じ名前のコースが本番にあります/)
      end

      it 'コースのクイズが最大の問題数を超えればエラーにする' do
        write_imports(quizzes: [ new_quiz ], courses: [ new_course.merge(max_questions: 1) ])

        expect { QuizImportService.call(dir: @dir) }.to raise_error(ArgumentError, /クイズが1問を超えています/)
      end

      it 'JSONにないkeyや本番にないクイズIDはエラーにする' do
        write_imports(courses: [ new_course.merge(quizzes: [ "vpn-9", 0 ]) ])

        expect { QuizImportService.call(dir: @dir) }
          .to raise_error(ArgumentError, /JSONにないkeyです: vpn-9\n.*本番にないクイズIDです: 0/)
      end
    end

    it 'バリデーションに引っかかれば、先に登録したクイズも元に戻す' do
      write_imports(quizzes: [ new_quiz, new_quiz.merge(key: "vpn-2", name: "あ" * 51) ])

      expect { QuizImportService.call(dir: @dir) }.to raise_error(ActiveRecord::RecordInvalid)
      expect(Quiz.count).to eq(1)
    end
  end
end
