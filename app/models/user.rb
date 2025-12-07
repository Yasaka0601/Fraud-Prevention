class User < ApplicationRecord
  # Include default devise modules. Others available are: (訳： デフォルトのDeviseモジュールを含める。その他利用可能なモジュールは次のとおりです：)
  # デフォルトのDeviseモジュールの一覧。 :confirmable, :lockable, :timeoutable, :trackable and :omniauthable

  # devise のモジュールを適用させている記述。
  # :validatable これは、子ユーザーの実装のために排除。
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable

  # アソシエーション
  belongs_to :room, optional: true

  # 各ユーザーの権限を定義。
  enum role: { general: 0, child: 1, admin: 2}

  # 各ユーザーの共通バリデーション
  validates :name, presence: true, length: { maximum: 50 }

  # 一般 & ホスト向け（子ユーザー以外）バリデーション
  # with_options で child? の条件を共通化。(child? は enum で自動で生成させるメソッド)
  with_options unless: :child? do
    validates :password,  presence: true,
                          confirmation: true,
                          length: { minimum: 6 },
                          if: -> { new_record? || changes[:encrypted_password] }
    validates :password_confirmation, presence: true,
                                      if: -> { new_record? || changes[:encrypted_password] }
    validates :email, presence: true,
                      uniqueness: true
  end

  # 子ユーザー向けバリデーション
  with_options if: :child? do
    validates :room_id, presence: true
  end
end

# 各モジュールの役割
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
