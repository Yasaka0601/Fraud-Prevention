module ApplicationHelper
  def avatar_image_tag(user, css_class: "user-avatar", alt: nil)
    alt ||= user.name
    if user.image.attached?
      image_tag user.image, class: css_class, alt: alt
    else
      image_tag "icon.png", class: css_class, alt: "デフォルトアイコン"
    end
  end

  # quiz: rooms: results: ranking: は key となる。
  # /home などのパスは active にしたいURLの 接頭辞(prefix)
  FOOTER_ACTIVE_PREFIXES = {
    quiz: [
      "/home",
      "/categories",
      "/courses",
      "/quizzes",
    ],
    rooms: [
      "/home_rooms",
      "/rooms",
      "/room_invitations",
    ],
    results: [
      "/result_users",
      "/results",
      "/result",
    ],
    ranking: [
      "/rankings",
    ],
  }

  # パスがどの key に属するのか判定している。
  def footer_active_key(path = request.path)
    FOOTER_ACTIVE_PREFIXES.each do |key, prefixes|
      # start_with? は「~で始まっている?」という意味。
      # any? は「どれか１つでも該当する項目がある？という意味。
      return key if prefixes.any? { |prefix| path.start_with?(prefix) }
    end
    nil
  end

  def footer_active_class(key, path = request.path)
    footer_active_key(path) == key ? "is-active" : ""
  end

  ##### メタタグ #####
  def show_meta_tags
    # display_meta_tags:
    # meta-tags gem が持っている「現在リクエストのメタタグ出力結果」を返す
    # まだ何も設定されていない場合は blank? になる
    assign_meta_tags if display_meta_tags.blank?
    display_meta_tags
  end

  def assign_meta_tags(options = {})
    # 指定なしの共通デフォルト
    defaults = {
      site: "詐欺対策道場",
      title: "詐欺対策道場",
      description: "特殊詐欺に関する知識を身につける",
      keywords: "詐欺対策,防犯,クイズ",
    }

    #コントローラーから渡した値で上書きしている。
    opts = defaults.merge(options)

    #コントローラーから渡されたURLがあれば opts[:url] を使う。
    #なければ現在URL (original_url) を使う。
    page_url = opts[:url].presence || request.original_url

    # 画像は全ページ固定
    fixed_image = image_url("ogp_default.png")

    # XにURLを貼ったときに出る「タイトル・説明・画像」を設定。
    twitter_config = {
      card: "summary_large_image",
      title: opts[:title].presence || opts[:site],
      description: opts[:description],
      image: fixed_image
    }

    # meta-tags gem に「リクエストのメタ情報」を登録
    set_meta_tags(
      separator: "|",
      reverse: true,
      site: opts[:site],
      title: opts[:title],
      description: opts[:description],
      keywords: opts[:keywords],
      canonical: page_url,
      noindex: !Rails.env.production?,
      og: {
        site_name: opts[:site],
        title: opts[:title].presence || opts[:site],
        description: opts[:description],
        type: "website",
        url: page_url,
        image: fixed_image,
        locale: "ja_JP"
      },
      twitter: twitter_config
    )
  end
end
