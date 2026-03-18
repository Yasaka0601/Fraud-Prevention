class User < ApplicationRecord
  ##### devise のモジュールを適用させている記述。#####
  devise  :database_authenticatable, :registerable,
          :recoverable, :rememberable, :omniauthable,
          :validatable, omniauth_providers: %i[line]

  ##### Active Storage #####
  has_one_attached :image

  ##### アソシエーション #####
  # optional: true は、presence バリデーションを自動で付けさせないための記述。
  belongs_to :room, optional: true
  has_many :course_results, dependent: :destroy
  has_many :user_course_challenges, dependent: :destroy
  has_many :user_badges, dependent: :destroy

  ##### 各ユーザーの権限を定義。#####
  enum role: { general: 0, admin: 1 }

  ##### バッジの選択（アイコン） #####
  enum :selected_badge_type, {
    white_belt:     0, # 白帯(1コースクリア)
    blue_belt:      1, # 青帯（５コースクリア）
    brown_belt:     2, # 茶帯（１０コースクリア）
    black_belt:     3, # 黒帯（１５コースクリア）
    master:         4, # 師範（全コースクリア）
    weekly_king:    5, # 頂点（１回目の１位）
    weekly_king_3:  6, # 覇者（３回目の１位）
    weekly_king_6:  7, # 鬼神（６回目の１位）
    weekly_king_10: 8, # 天下無双（１０回目の１位）
    weekly_second:  9, # 銀将（１回目の２位）
    weekly_third:   10 # 銅将（１回目の３位）
  }

  ##### バリデーション #####
  validates :name, presence: true, length: { maximum: 50 }

  ##### 画像ファイルの種類とサイズのバリデーション #####
  ACCEPTED_CONTENT_TYPES = %w[image/jpeg image/png image/gif image/webp].freeze
  validates :image, content_type: ACCEPTED_CONTENT_TYPES,
                    size: { less_than_or_equal_to: 5.megabytes }

  ##### ユーザー情報更新時、current_password 要求を省略するメソッド #####
  def update_without_current_password(params, *options)
    params.delete(:current_password)

    if params[:password].blank? && params[:password_confirmation].blank?
      params.delete(:password)
      params.delete(:password_confirmation)
    end

    result = update(params, *options)
    clean_up_passwords
    result
  end

  ##### LINE ログインに必要な記述 #####
  def social_profile(provider)
    social_profiles.select { |sp| sp.provider == provider.to_s }.first
  end

  def set_values(omniauth)
    return if provider.to_s != omniauth["provider"].to_s || uid != omniauth["uid"]
    credentials = omniauth["credentials"]
    info = omniauth["info"]

    access_token = credentials["refresh_token"]
    access_secret = credentials["secret"]
    credentials = credentials.to_json
    name = info["name"]
  end

  def set_values_by_raw_info(raw_info)
    self.raw_info = raw_info.to_json
    self.save!
  end
end

#####  メモ   #####

# Devise の各モジュールの役割
# 1. :database_authenticatable
# •	メールアドレス＋パスワードでログインするための機能。
# •	パスワードをハッシュ化して encrypted_password に保存
# •	ログイン時に平文パスワードと encrypted_password を照合
# •	valid_password? みたいなメソッドを生やす

# 2. :registerable
# •	ユーザーの新規登録・編集・削除まわりの機能。
# •	Devise::RegistrationsController と組み合わせて
#   サインアップ（/users/sign_up）,アカウント編集,アカウント削除などをやってくれる。

# 3. :recoverable
# •	パスワードリセット機能。
# •	reset_password_token, reset_password_sent_at のカラムを使って、
# •	「パスワードを忘れた→ メール送る → メールに入っているURLからパスワード再設定」という仕組みを提供してる。

# 4. :rememberable
# •	「ログイン状態を保持する（ログインしたままにする）」機能。
# •	remember_me チェックボックスとかとセットで使うやつ。
# •	remember_created_at カラムを使って、ブラウザのクッキーに情報を保存しておいて、次回来たときに自動ログインさせる。

# 5. :validatable
# •	email と password にデフォルトのバリデーションを自動で追加するモジュール。
# •	email の presence: true（必須） と uniqueness: true（ユニーク） と format（メールアドレスっぽい形式かどうか）
# •	password の presence: true（必須） と length（デフォルト6文字以上） と confirmation（確認用パスワードと一致）
