import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["resultArea"]

  scrollToResult(event) {
    if (!event.detail?.success) return
    if (!event.target?.dataset?.quizScrollForm) return
    if (!this.hasResultAreaTarget) return

    // Turbo StreamのDOM反映後まで少し待ってからスクロールする
    const smoothScroll = () => {
      const headerOffset = 72 // 固定ヘッダー高さに合わせて調整
      // top は結果エリアの座標を格納している。（ヘッダーの高さを引いた値）
      const top = this.resultAreaTarget.getBoundingClientRect().top + window.scrollY - headerOffset
      // window.sctollTo はWebAPI behavior: "smooth" で滑らかにスクロールしている。
      window.scrollTo({ top, behavior: "smooth" })
    }

    // requestAnimationFrame はブラウザ標準のAPI
    // DOM更新後の位置が安定してからスクロールするため。
    requestAnimationFrame(() => requestAnimationFrame(smoothScroll))
  }
}
