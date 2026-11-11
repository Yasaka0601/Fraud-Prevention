class QuizUpdateService
  QUIZ_KEYS = %w[id name sentence explanation give_point choices].freeze
  CHOICE_KEYS = %w[id text is_correct].freeze

  def self.call(dir:, dry_run: false)
    new(dir, dry_run).call
  end

  def initialize(dir, dry_run)
    @dir = Pathname(dir)
    @dry_run = dry_run
  end

  def call
    updates = load_updates
    errors = check(updates)
    raise ArgumentError, errors.join("\n") if errors.any?

    ActiveRecord::Base.transaction do
      updates.flat_map { |update| apply(update) }
    end
  end

  private

  # ① tmp/quiz_updates/*.json をファイル名の順に読み、クイズを1つの配列にまとめる
  def load_updates
    Dir.glob(@dir.join("*.json")).sort.flat_map do |path|
      JSON.parse(File.read(path)).fetch("quizzes")
    end
  end

  # ② 全部のクイズをチェックし、見つかった問題をすべて返す
  def check(updates)
    errors = []

    duplicated_ids = updates.map { |update| update["id"] }.tally.select { |_id, count| count > 1 }.keys
    errors << "同じクイズIDが2回以上あります: #{duplicated_ids.join(', ')}" if duplicated_ids.any?

    updates.each do |update|
      errors.concat(check_quiz(update))
    end

    errors
  end

  def check_quiz(update)
    quiz = Quiz.find_by(id: update["id"])
    return [ "クイズID #{update['id']}: 本番にありません" ] unless quiz

    errors = []
    unknown_keys = update.keys - QUIZ_KEYS
    errors << "クイズID #{quiz.id}: 知らない項目があります: #{unknown_keys.join(', ')}" if unknown_keys.any?

    choices = update["choices"] || quiz.choices.map { |choice| { "is_correct" => choice.is_correct } }

    if update.key?("choices")
      if update["choices"].map { |choice| choice["id"] }.sort != quiz.choices.ids.sort
        errors << "クイズID #{quiz.id}: 選択肢のIDが本番と一致しません（数を変える・別のクイズの選択肢を指定することはできません）"
      end

      unknown_choice_keys = update["choices"].flat_map(&:keys).uniq - CHOICE_KEYS
      errors << "クイズID #{quiz.id}: 選択肢に知らない項目があります: #{unknown_choice_keys.join(', ')}" if unknown_choice_keys.any?
    end

    correct_count = choices.count { |choice| choice["is_correct"] }
    errors << "クイズID #{quiz.id}: 正解の選択肢がありません" if correct_count.zero?

    errors
  end

  # ③ 1問分の新しい値をセットし、差分を返す。DRY_RUN でなければ保存する
  def apply(update)
    quiz = Quiz.includes(:choices).find(update["id"])
    quiz.assign_attributes(update.slice("name", "sentence", "explanation", "give_point"))

    choices = (update["choices"] || []).map do |choice_update|
      choice = quiz.choices.find { |c| c.id == choice_update["id"] }
      choice.assign_attributes(choice_update.slice("text", "is_correct"))
      choice
    end

    quiz.validate!
    choices.each(&:validate!)

    lines = describe_changes("クイズID #{quiz.id}", quiz.changes) +
      choices.flat_map { |choice| describe_changes("クイズID #{quiz.id} 選択肢ID #{choice.id}", choice.changes) }

    unless @dry_run
      quiz.save!
      choices.each(&:save!)
    end

    lines
  end

  # 「どこの / 何が / 今 → 新」の文字列にする
  def describe_changes(label, changes)
    changes.except("updated_at").map do |attribute, (before, after)|
      "#{label} #{attribute}\n  今: #{before.inspect}\n  新: #{after.inspect}"
    end
  end
end
