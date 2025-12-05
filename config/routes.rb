Rails.application.routes.draw do

  # Devise が users 用のルーティングをまとめて定義
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions:      'users/sessions',
    passwords:     'users/passwords'
  }
  #ルートパスにアクセスされたら、TopsControllerのtopアクションを呼ぶ。
  root "tops#top"

  get "home", to: "homes#home"

  resources :rooms, only: %i[new create edit update destroy] do
    collection do
      get :home
      # 家族ルーム作成機能の実装完了まで、招待機能のルーティングはコメントに。
      # resources :invitations, only: %i[ show new create edit update ]
    end
  end

#アプリが動いているかhealth_checkするルート。
  get "up" => "rails/health#show", as: :rails_health_check

# PWA用のservice worker（ブラウザ側で動くJS）を返すルート。PWAとは、簡単に言うと「アプリっぽく動かす仕組み」
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

# PWA用の設定ファイル（アプリアイコンや名前などの情報）を返すルート。
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

# letter_opener_web のルーティング。
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
end
