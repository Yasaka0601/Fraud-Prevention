Rails.application.routes.draw do
  ##### adminでログイン中 → /admin というルートが生える。 #####
  authenticate :user, ->(u) { u.admin? } do
    mount RailsAdmin::Engine => "/admin", as: "rails_admin"
  end

  ##### Devise が users 用のルーティングをまとめて定義している #####
  devise_for :users, controllers: {
    registrations: "users/registrations",
    sessions:      "users/sessions",
    passwords:     "users/passwords",
    omniauth_callbacks: "omniauth_callbacks"
  }

  ##### ルートパスにアクセスされたら、TopsControllerのtopアクションを呼ぶ。 #####
  root "tops#top"

  get "home", to: "homes#home"

  ##### 家族ルームのルーティング #####
  resources :rooms, only: %i[new create edit update destroy] do
      # collection は id を持たないルーティングを生成。（その逆はmember)
      get :home, on: :collection
      # rooms に invitations をネストさせて、/rooms/:room_id/invitations/new みたいなパスを作成。
      resources :invitations, only: %i[ show new create edit update ] do
        get "join/:token", action: :edit, as: :join, on: :member
      end
  end

  ##### カテゴリーとコースのルーティング #####
  # ネストさせることで、categories/ id /courses というパスを作成
  resources :categories do
    resources :courses, only: [ :index ]
  end

  ##### クイズ画面のルーティング。#####
  # /courses/:course_id/quiz/:id というパスを生成している。
  # :quiz に post :answer をネストさせ /courses/:course_id/quiz/:id/answer パスを生成。
  resources :courses do
    resources :quiz, only: [ :show ], controller: "quizzes" do
      post :answer, on: :member
      get :guest_result, on: :collection
    end
  end

  ##### 成績表示のルーティング #####
  get "results/users", to: "results#users", as: :result_users
  get "share/results/:token", to: "share_results#show", as: :share_result
  resources :results, only: [ :index, :show ]

  ##### ランキングのルーティング #####
  resources :rankings, only: [ :index ]

  ##### 未ログインのユーザーのルーティング #####
  get "guest", to: "guest#show", as: :guest

  ##### 利用規約・ポリシーページ #####
  get "/terms", to: "legal#terms"
  get "/privacy", to: "legal#privacy"

  ##### プロフィールページのルーティング #####
  resources :users, only: [ :show ], param: :public_id, controller: "users/users"

  ##### アプリが動いているかhealth_checkするルート。 #####
  get "up" => "rails/health#show", as: :rails_health_check

  ##### PWA用のservice worker（ブラウザ側で動くJS）を返すルート。PWAとは、簡単に言うと「アプリっぽく動かす仕組み」 #####
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  ##### PWA用の設定ファイル（アプリアイコンや名前などの情報）を返すルート。#####
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  ##### letter_opener_web のルーティング。（ぶっちゃけ使ってない）#####
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
end
