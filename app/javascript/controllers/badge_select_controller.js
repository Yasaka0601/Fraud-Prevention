// Stimulus の Controller クラスを読み込む（Rubyの require に相当）
import { Controller } from "@hotwired/stimulus"

// このコントローラーを外部から使えるようにして定義する
export default class extends Controller {

  // このコントローラーが操作するHTML要素に名前をつける
  // HTMLで data-badge-select-target="〇〇" と書いて紐づける
  static targets = ["avatarBadge", "buttonContent", "radioLabel"]

  // ページ読み込み時に自動実行される（before_action に近い）
  connect() {
    // 現在チェック済みのラジオボタン要素を取得する
    const checked = this.element.querySelector('input[name="user[selected_badge_type]"]:checked')
    // チェック済みがあればそのvalue、なければ "" を currentValue に保存する
    // キャンセル時にラジオを元に戻すために使う
    this.currentValue = checked ? checked.value : ""
  }

  // 「選択」ボタンを押した時に実行される
  apply() {
    // その時点でチェック済みのラジオボタン要素を取得する
    const checked = this.element.querySelector('input[name="user[selected_badge_type]"]:checked')
    // ラジオが見つからなければ処理を中断する（安全のための保険）
    if (!checked) return

    // チェック済みラジオの value（例: "white_belt" または ""）を取得する
    const badgeType = checked.value
    // radioLabelTargets の中から data-badge-type が一致するラベルを探す
    const label = this.radioLabelTargets.find(l => l.dataset.badgeType === badgeType)
    // ラベルが見つからなければ処理を中断する（安全のための保険）
    if (!label) return

    // 「表示しない」が選ばれた場合
    if (badgeType === "") {
      // アバターのバッジエリアの中身を空にする
      this.avatarBadgeTarget.innerHTML = ""
      // アバターのバッジエリアを非表示にする
      this.avatarBadgeTarget.hidden = true
      // ボタン内の表示を「表示しない」テキストに書き換える
      this.buttonContentTarget.innerHTML = `<span class="badge-select-name text-gray-400">表示しない</span>`
    } else {
      // バッジが選ばれた場合
      // ラベルの中からアイコンエリア（SVGが入っているdiv）を取得する
      const iconEl = label.querySelector(".badge-radio-icon")
      // アイコンエリアがあればその中のHTML（SVG）を文字列として取り出す
      const iconHtml = iconEl ? iconEl.innerHTML : ""

      // アバターのバッジエリアにSVGを注入する
      this.avatarBadgeTarget.innerHTML = iconHtml
      // アバターのバッジエリアを表示する
      this.avatarBadgeTarget.hidden = false
      // ボタン内の表示をアイコン＋バッジ名に書き換える
      this.buttonContentTarget.innerHTML = `
        <div class="badge-select-icon">${iconHtml}</div>
        <span class="badge-select-name">${label.dataset.badgeName}</span>
      `
    }

    // 適用済みの値を更新する（キャンセル時に元に戻すために使う）
    this.currentValue = badgeType
    // モーダルを閉じる
    document.getElementById("badge_modal").close()
  }

  // 「キャンセル」ボタンを押した時に実行される
  cancel() {
    // すべてのラジオラベルをループする
    this.radioLabelTargets.forEach(label => {
      // そのラベルの中のラジオボタン要素を取得する
      const radio = label.querySelector("input[type='radio']")
      // ラジオが存在すれば、currentValue と一致するものだけ checked にする
      // 一致しないものは false になるので、選択が元に戻る
      if (radio) radio.checked = radio.value === this.currentValue
    })
    // モーダルを閉じる
    document.getElementById("badge_modal").close()
  }
}
