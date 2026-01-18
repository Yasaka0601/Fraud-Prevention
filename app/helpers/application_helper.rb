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
      "/plays",
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

end