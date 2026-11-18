class QuizImportService
  QUIZ_KEYS = %w[key name sentence explanation give_point categories choices].freeze
  CHOICE_KEYS = %w[text is_correct].freeze
  COURSE_KEYS = %w[name category max_questions quizzes].freeze

  def self.call(dir:, dry_run: false)
    new(dir, dry_run).call
  end

  def initialize(dir, dry_run)
    @dir = Pathname(dir)
    @dry_run = dry_run
  end

  def call
    data = load_data
    errors = check(data)
    raise ArgumentError, errors.join("\n") if errors.any?

    lines = []
    ActiveRecord::Base.transaction do
      new_quizzes = data["quizzes"].to_h { |attrs| [ attrs["key"], create_quiz(attrs, lines) ] }
      data["courses"].each { |attrs| create_course(attrs, new_quizzes, lines) }
    end
    lines
  end

  private

  # ① tmp/quiz_imports/*.json をファイル名の順に読み、クイズとコースをまとめる
  def load_data
    files = Dir.glob(@dir.join("*.json")).sort.map { |path| JSON.parse(File.read(path)) }
    {
      "quizzes" => files.flat_map { |file| file.fetch("quizzes", []) },
      "courses" => files.flat_map { |file| file.fetch("courses", []) }
    }
  end

  # ② 全部をチェックし、見つかった問題をすべて返す
  def check(data)
    errors = []
    keys = data["quizzes"].map { |quiz| quiz["key"] }
    duplicated_keys = keys.tally.select { |_key, count| count > 1 }.keys
    errors << "同じkeyが2回以上あります: #{duplicated_keys.join(', ')}" if duplicated_keys.any?

    category_names = Category.pluck(:name)
    data["quizzes"].each { |quiz| errors.concat(check_quiz(quiz, category_names)) }
    data["courses"].each { |course| errors.concat(check_course(course, keys, category_names)) }
    errors
  end

  def check_quiz(quiz, category_names)
    label = "クイズ #{quiz['key']}"
    errors = []
    choices = Array(quiz["choices"])

    unknown_keys = quiz.keys - QUIZ_KEYS
    errors << "#{label}: 知らない項目があります: #{unknown_keys.join(', ')}" if unknown_keys.any?
    missing_categories = Array(quiz["categories"]) - category_names
    errors << "#{label}: 本番にないカテゴリです: #{missing_categories.join(', ')}" if missing_categories.any?
    unknown_choice_keys = choices.flat_map(&:keys).uniq - CHOICE_KEYS
    errors << "#{label}: 選択肢に知らない項目があります: #{unknown_choice_keys.join(', ')}" if unknown_choice_keys.any?
    errors << "#{label}: 選択肢が2つ未満です" if choices.size < 2
    errors << "#{label}: 正解の選択肢がありません" if choices.none? { |choice| choice["is_correct"] == true }
    errors
  end

  def check_course(course, keys, category_names)
    label = "コース「#{course['name']}」"
    errors = []
    refs = Array(course["quizzes"])

    unknown_keys = course.keys - COURSE_KEYS
    errors << "#{label}: 知らない項目があります: #{unknown_keys.join(', ')}" if unknown_keys.any?
    errors << "#{label}: 同じ名前のコースが本番にあります" if Course.exists?(name: course["name"])
    errors << "#{label}: 本番にないカテゴリです: #{course['category']}" unless category_names.include?(course["category"])
    errors << "#{label}: クイズが#{course['max_questions']}問を超えています" if refs.size > course["max_questions"].to_i
    errors << "#{label}: 同じクイズが2回入っています" if refs.uniq.size != refs.size

    unknown_refs = refs.grep(String) - keys
    errors << "#{label}: JSONにないkeyです: #{unknown_refs.join(', ')}" if unknown_refs.any?
    ids = refs.grep(Integer)
    missing_ids = ids - Quiz.where(id: ids).ids
    errors << "#{label}: 本番にないクイズIDです: #{missing_ids.join(', ')}" if missing_ids.any?
    errors
  end

  # ③ クイズ1問を、選択肢・カテゴリと一緒に作る
  #    DRY_RUN のときは保存せずにバリデーションだけ行う（保存するとIDの番号が使われ、取り消しても戻らないため）
  def create_quiz(attrs, lines)
    quiz = Quiz.new(attrs.slice("name", "sentence", "explanation", "give_point"))
    quiz.categories = Category.where(name: attrs["categories"])
    attrs["choices"].each { |choice| quiz.choices.build(choice.slice("text", "is_correct")) }

    if @dry_run
      quiz.validate!
      lines << "クイズ #{attrs['key']}「#{quiz.name}」"
    else
      quiz.save!
      lines << "クイズ #{attrs['key']} → ID #{quiz.id}「#{quiz.name}」"
    end
    quiz
  end

  # ④ コースを作り、クイズを入れる（数字は本番のクイズID、文字列は今回作ったクイズ）
  def create_course(attrs, new_quizzes, lines)
    course = Course.new(name: attrs["name"], max_questions: attrs["max_questions"],
                        category: Category.find_by!(name: attrs["category"]))
    quizzes = attrs["quizzes"].map { |ref| ref.is_a?(Integer) ? Quiz.find(ref) : new_quizzes.fetch(ref) }

    if @dry_run
      course.validate!
      lines << "コース「#{course.name}」（#{attrs['category']}）: クイズ #{attrs['quizzes'].join(', ')}"
      return
    end

    course.save!
    quizzes.each { |quiz| course.course_quizzes.create!(quiz: quiz) }
    lines << "コース「#{course.name}」（#{attrs['category']}）→ ID #{course.id}: クイズID #{course.quiz_ids.join(', ')}"
  end
end
