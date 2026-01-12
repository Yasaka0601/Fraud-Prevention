module ApplicationHelper
  def avatar_image_tag(user, css_class: "user-avatar", alt: nil)
    alt ||= user.name
    if user.image.attached?
      image_tag user.image, class: css_class, alt: alt
    else
      image_tag "icon.png", class: css_class, alt: "デフォルトアイコン"
    end
  end
end