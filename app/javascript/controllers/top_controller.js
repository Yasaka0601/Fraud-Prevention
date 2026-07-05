import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="top"
export default class extends Controller {
  static targets = ["title", "lead", "step", "hero_image"]

  connect() {
    const title = this.titleTarget // title 要素を取得
    const hero_image = this.hero_imageTarget //hero_image 要素を取得
    const lead = this.leadTarget // lead 要素を取得
    const steps = this.stepTargets // step 要素をまとめて取得（複数形）


    //==== title のアニメーション ======
    const show_title = (entries) => {
      //console.log(title)
      const keyframes = {
        opacity: [0, 1],
        translate: ['0 50px', 0],
      };

      const options = {
        duration: 1000,
        easing: 'ease',
      };

      if(entries[0].isIntersecting) {
        entries[0].target.animate(keyframes, options);}
    }
    //==============================

    //===== hero_image のアニメーション=====
    const show_hero_image = (entries) => {
      const keyframes = {
        scale: [1, 1.08], // 少しずつ拡大する
      };

      const options = {
        duration: 8000, // 8秒かけてゆっくり
        easing: 'ease-out',
        fill: 'forwards', // 拡大しきった状態を維持する
      };

      if (entries[0].isIntersecting) {
        entries[0].target.animate(keyframes, options);
      }
    }
    //===================================

    //===== lead のアニメーション =====
    const show_lead = (entries) => {
      const keyframes = {
        opacity: [0, 1],
        translate: ['0 50px', 0],
      };

      const options = {
        duration: 1000,
        easing: 'ease',
        delay: 300, // title より少し遅れて表示
      };

      if (entries[0].isIntersecting) {
        entries[0].target.animate(keyframes, options);
      }
    }
    //===============================

    //===== step のアニメーション ======
    const show_step = (entries) => {

      const keyframes = {
        opacity: [0, 1],
        translate: ['0 50px', 0],
      };

      const options = {
        duration: 1000,
        easing: 'ease',
      };

      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          entry.target.animate(keyframes, options);
        }
      })
    }
    //============================

    // ===== 監視ロボットの設定 =====
    const titleObserver = new IntersectionObserver(show_title);
    const hero_imageObserver = new IntersectionObserver(show_hero_image);
    const leadObserver = new IntersectionObserver(show_lead);
    const stepObserver = new IntersectionObserver(show_step);

    // ===== 要素を監視するよう指示 =====
    titleObserver.observe(title);
    hero_imageObserver.observe(hero_image)
    leadObserver.observe(lead);
    steps.forEach((step) => stepObserver.observe(step));
  }
}
