Rails.application.routes.draw do #ルーティングを定義する宣言
  root "homes#top" #ルートパスにアクセスされたら、HomesControllerのtopアクションを呼ぶ。

  get "up" => "rails/health#show", as: :rails_health_check
  #アプリが動いているかhealth_checkするルート。

  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  # PWA用のservice worker（ブラウザ側で動くJS）を返すルート。PWAとは、簡単に言うと「アプリっぽく動かす仕組み」
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # PWA用の設定ファイル（アプリアイコンや名前などの情報）を返すルート。
end
