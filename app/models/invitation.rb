class Invitation < ApplicationRecord

  ##### バリデーション #####
  validates :room_id, presence: true
  validates :token_digest, presence: true

  ##### アソシエーション #####
  belongs_to :room

  ##### 生のトークンを一時保存。@invitation_token を生成 #####
  attr_accessor :invitation_token

  ##### ランダムなトークンを生成 #####
  # SecureRandom.urlsafe_base64 とは、安全なランダムの文字列を作成する。
  def self.new_token
    SecureRandom.urlsafe_base64
  end

  ##### 渡された文字列のハッシュ値を返す #####
  def self.digest(string)
    # cost = 計算コスト（大きいほどセキュリティ高いけど重くなる）
    # BCrypt::Engine::MIN_COST テスト環境などでは軽くする。
    # BCrypt::Engine.cost  本番などでは重めにする。(ちなみに、これは三項演算子）
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost

    # 渡された文字列を BCrypt でハッシュ化して返す
    BCrypt::Password.create(string, cost: cost)
  end

  ##### トークンを生成。ハッシュ化。生成の時間。 #####
  def create_invitation_digest
    # 上記の self.new_token メソッドを使って、ランダムな生トークンを生成している。
    # インスタンス変数 @invitation_token に入れている。
    self.invitation_token = Invitation.new_token

    # 上記の self.digest メソッドを使って DB に保存するために、トークンをハッシュ化している。
    self.token_digest = Invitation.digest(invitation_token)

    # トークンを生成した時間をセットしている。
    self.send_token_at = Time.zone.now
    save!
  end

  ##### トークンが正しいものか確認するメソッド #####
  def authenticated?(invitation_token)
    # token_digest が空なら false を返している。
    return false if token_digest.blank?
    # token_digest から BCrypt オブジェクトを作る。
    # 渡された invitation_token と「同じ元文字列か？」をチェック
    BCrypt::Password.new(token_digest).is_password?(invitation_token)
  end

  ##### トークンが有効期限内かどうか確認するメソッド #####
  def invitation_expired?
    # トークン発行から1日以上経っていたら true（期限切れ）
    send_token_at < 1.days.ago
  end

  ##### viewで招待リンクの有効期限を表示するためのフォーマット調整 #####
  def expiration_time
    # 有効期限（発行から1日後）を "2026年12月08日 14:30" のような文字列にする
    (send_token_at + 1.days).strftime("%Y年%m月%d日 %H:%M")
  end
end
