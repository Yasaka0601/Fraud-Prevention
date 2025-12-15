Rails.application.routes.draw do
  ##### adminでログイン中 → /admin というルートが生える。 #####
  authenticate :user, ->(u) { u.admin? } do
    mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  end

  ##### Devise が users 用のルーティングをまとめて定義している #####
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions:      'users/sessions',
    passwords:     'users/passwords'
  }

  ##### ルートパスにアクセスされたら、TopsControllerのtopアクションを呼ぶ。 #####
  root "tops#top"

  get "home", to: "homes#home"

  resources :rooms, only: %i[new create edit update destroy] do
    collection do
      get :home
    end
      # rooms に invitations をネストさせて、/rooms/:room_id/invitations/new みたいなパスを作成。
      resources :invitations, only: %i[ show new create edit update ]
  end

  # categories に courses をネストさせたいだけなので、only 指定はしない。
  resources :categories, only: [] do
    resources :courses, only: [:index]
  end

  # クイズ画面のルーティング。/courses/:course_id/play/:id というパスを生成している。
  resources :courses, only: [] do
    resources :play, only: [:show], controller: 'plays'
    # post :answer, on: :member
    # collection do
    #   get :select
    #   get :result
    # end
  end

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
