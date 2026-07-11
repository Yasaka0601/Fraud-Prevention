import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["category_grid"]

  connect(){
    const category_grid = this.category_gridTarget //category_grid 要素を取得

    //===== category_grid のアニメーション =====

    // 下から浮き上がるアニメーション ==
    const show_category_grid = (entries) => {
      const keyframes = {
        opacity: [0, 1],
        translate: ['0 45px', 0],
      }

      const options = {
        duration: 1000,
        easing: 'ease',
      };

      if(entries[0].isIntersecting) {
      entries[0].target.animate(keyframes, options);}
    }


    // ===== 監視ロボットの設定 =====
    const category_gridObserver = new IntersectionObserver(show_category_grid);

    // ===== 要素を監視するよう指示 ====
    category_gridObserver.observe(category_grid);
  }
}