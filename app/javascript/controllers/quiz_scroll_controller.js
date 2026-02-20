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
      const top = this.resultAreaTarget.getBoundingClientRect().top + window.scrollY - headerOffset
      window.scrollTo({ top, behavior: "smooth" })
    }

    requestAnimationFrame(() => requestAnimationFrame(smoothScroll))
  }
}
