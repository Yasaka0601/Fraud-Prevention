import { Controller } from "@hotwired/stimulus"

// 画像選択時のローディング表示とプレビュー更新を制御する

export default class extends Controller {
  static targets = ["preview", "fileInput", "loading"]

  connect() {
    this.currentObjectUrl = null
    this.loadingStartedAt = null
    this.loadingTimer = null
    this.previewRequestId = 0
    this.hideLoading()
  }

  disconnect() {
    if (this.loadingTimer) clearTimeout(this.loadingTimer)
    this.revokeCurrentObjectUrl()
    this.hideLoading()
  }

  preview() {
    const file = this.hasFileInputTarget ? this.fileInputTarget.files?.[0] : null
    if (!file) return

    const requestId = ++this.previewRequestId
    const nextObjectUrl = URL.createObjectURL(file)

    this.showLoading()
    this.hidePreview()

    // 表示用imgとは別に先読みして、読み込み成功後にのみ差し替える
    const preloadImage = new Image()
    preloadImage.onload = () => this.finalizePreview(requestId, nextObjectUrl)
    preloadImage.onerror = () => this.handlePreviewError(requestId, nextObjectUrl)
    preloadImage.src = nextObjectUrl
  }

  finalizePreview(requestId, nextObjectUrl) {
    if (requestId !== this.previewRequestId) {
      URL.revokeObjectURL(nextObjectUrl)
      return
    }

    const elapsed = this.loadingStartedAt ? Date.now() - this.loadingStartedAt : 0
    const wait = Math.max(1000 - elapsed, 0)

    if (this.loadingTimer) clearTimeout(this.loadingTimer)

    this.loadingTimer = setTimeout(() => {
      if (requestId !== this.previewRequestId) {
        URL.revokeObjectURL(nextObjectUrl)
        return
      }

      // ローディングを先に消し、次フレームで画像を切り替える
      this.hideLoading()

      requestAnimationFrame(() => {
        if (requestId !== this.previewRequestId) {
          URL.revokeObjectURL(nextObjectUrl)
          return
        }

        if (this.hasPreviewTarget) {
          this.revokeCurrentObjectUrl()
          this.previewTarget.src = nextObjectUrl
          this.previewTarget.alt = "選択中のアイコン画像プレビュー"
          this.showPreview()
          this.currentObjectUrl = nextObjectUrl
        } else {
          URL.revokeObjectURL(nextObjectUrl)
        }

        this.loadingTimer = null
      })
    }, wait)
  }

  handlePreviewError(requestId, nextObjectUrl) {
    if (requestId !== this.previewRequestId) {
      URL.revokeObjectURL(nextObjectUrl)
      return
    }

    URL.revokeObjectURL(nextObjectUrl)
    this.hideLoading()
    this.showPreview()
  }

  showLoading() {
    if (this.loadingTimer) clearTimeout(this.loadingTimer)
    if (this.hasLoadingTarget) this.loadingTarget.classList.remove("hidden")
    this.loadingStartedAt = Date.now()
  }

  hideLoading() {
    if (this.hasLoadingTarget) this.loadingTarget.classList.add("hidden")
    this.loadingStartedAt = null
  }

  hidePreview() {
    if (this.hasPreviewTarget) this.previewTarget.classList.add("invisible")
  }

  showPreview() {
    if (this.hasPreviewTarget) this.previewTarget.classList.remove("invisible")
  }

  revokeCurrentObjectUrl() {
    if (this.currentObjectUrl) {
      URL.revokeObjectURL(this.currentObjectUrl)
      this.currentObjectUrl = null
    }
  }
}
