class QuizExportService
  def self.call(dir:)
    new(dir).call
  end

  def initialize(dir)
    @dir = Pathname(dir)
  end

  def call
    quizzes = Quiz.includes(:choices, :categories, :courses, image_attachment: :blob)
                  .order(:id)
                  .map { |quiz| quiz_to_hash(quiz) }

    FileUtils.mkdir_p(@dir)
    File.write(@dir.join("quizzes.json"), to_json(quizzes))
    File.write(@dir.join("quizzes.md"), to_markdown(quizzes))

    quizzes.size
  end

  private

  def quiz_to_hash(quiz)
    {
      id: quiz.id,
      name: quiz.name,
      sentence: quiz.sentence,
      explanation: quiz.explanation,
      give_point: quiz.give_point,
      categories: quiz.categories.map(&:name),
      courses: quiz.courses.map(&:name),
      image_filename: quiz.image.attached? ? quiz.image.filename.to_s : nil,
      choices: quiz.choices.sort_by(&:id).map { |choice| { text: choice.text, is_correct: choice.is_correct } },
      created_at: quiz.created_at
    }
  end

  def to_json(quizzes)
    JSON.pretty_generate(exported_at: Time.current, count: quizzes.size, quizzes: quizzes)
  end

  def to_markdown(quizzes)
    lines = [ "# クイズ一覧（#{quizzes.size}問）", "" ]

    quizzes.each do |quiz|
      lines << "## #{quiz[:id]}. #{quiz[:name]}"
      lines << "- カテゴリ: #{quiz[:categories].join('、')}"
      lines << "- コース: #{quiz[:courses].join('、')}"
      lines << "- ポイント: #{quiz[:give_point]}"
      lines << ""
      lines << "### 問題文"
      lines << quiz[:sentence]
      lines << ""
      lines << "### 選択肢"
      quiz[:choices].each do |choice|
        lines << "- #{choice[:is_correct] ? '✅' : '⬜'} #{choice[:text]}"
      end
      lines << ""
      lines << "### 解説"
      lines << quiz[:explanation].to_s
      lines << ""
    end

    lines.join("\n")
  end
end
