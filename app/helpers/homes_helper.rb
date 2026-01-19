module HomesHelper
  # カテゴリーでアイコンを出し分けるメソッド
  def category_icon_svg(category)
    key = category.name.to_s

    case key
    when /不審電話/
      phone_icon_svg
    # when /メール/ カテゴリーを追加すればコメントを外す
    #  mail_icon_svg
    else
      shield_icon_svg # 汎用のアイコン
    end
  end

  def phone_icon_svg
    <<~SVG.html_safe
      <svg  xmlns="http://www.w3.org/2000/svg"
      fill="none"
      viewBox="0 0 24 24"
      stroke-width="1.5"
      stroke="currentColor"
      class="size-8">
      <path stroke-linecap="round"
      stroke-linejoin="round"
      d="M2.25 6.75c0 8.284 6.716 15 15 15h2.25a2.25 2.25 0 0 0 2.25-2.25v-1.372c0-.516-.351-.966-.852-1.091l-4.423-1.106c-.44-.11-.902.055-1.173.417l-.97 1.293c-.282.376-.769.542-1.21.38a12.035 12.035 0 0 1-7.143-7.143c-.162-.441.004-.928.38-1.21l1.293-.97c.363-.271.527-.734.417-1.173L6.963 3.102a1.125 1.125 0 0 0-1.091-.852H4.5A2.25 2.25 0 0 0 2.25 4.5v2.25Z" />
      </svg>
    SVG
  end

  # def mail_icon_svg
  # end

  def shield_icon_svg
    <<~SVG.html_safe
      <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"
           stroke-width="1.5" stroke="currentColor" class="size-8">
        <path stroke-linecap="round" stroke-linejoin="round"
              d="M12 3.75c-2.43 1.8-5.37 2.7-8.25 2.7v6.48c0 5.06 3.58 9.68 8.25 10.82 4.67-1.14 8.25-5.76 8.25-10.82V6.45c-2.88 0-5.82-.9-8.25-2.7Z" />
      </svg>
    SVG
  end

  # カテゴリーで説明文を出し分ける。
  def category_desc(category)
    key = category.name.to_s

    case key
    when /不審電話/
      "オレオレ詐欺や還付金詐欺など、電話による巧妙な詐欺をを見極める稽古。"
    # when /メール/
    #  "架空請求メールやフィッシングを見抜き、冷静に対処する練習。"
    else
      "巧妙な詐欺手口を見抜く力を鍛える稽古。"
    end
  end

end

