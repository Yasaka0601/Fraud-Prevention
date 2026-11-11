require 'rails_helper'

RSpec.describe Quiz, type: :model do
  describe 'バリデーション' do
    # Quizモデルの入力制約（必須・文字数上限）を担保する。
    subject(:quiz) { described_class.new }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_most(50) }
    it { is_expected.to validate_presence_of(:sentence) }

    describe 'PR欄' do
      subject(:quiz) { described_class.new(name: 'テスト', sentence: '問題文') }

      it 'URLもリンク文字も空なら有効' do
        expect(quiz).to be_valid
      end

      it 'https のURLとリンク文字があれば有効' do
        quiz.assign_attributes(affiliate_url: 'https://px.a8.net/svt/ejp?a8mat=xxx', affiliate_text: 'おすすめのVPN')
        expect(quiz).to be_valid
      end

      it 'http(s) 以外で始まるURLは無効' do
        quiz.assign_attributes(affiliate_url: 'javascript:alert(1)', affiliate_text: 'リンク')
        expect(quiz).not_to be_valid
      end

      it 'URLがあるのにリンク文字が空なら無効' do
        quiz.affiliate_url = 'https://example.com'
        expect(quiz).not_to be_valid
      end
    end
  end

  describe 'アソシエーション' do
    # クイズと選択肢/中間テーブル/関連先モデルの関連定義を担保する。
    it { is_expected.to have_many(:choices).dependent(:destroy) }
    it { is_expected.to have_many(:course_quizzes).dependent(:destroy) }
    it { is_expected.to have_many(:courses).through(:course_quizzes) }
    it { is_expected.to have_many(:quiz_categories).dependent(:destroy) }
    it { is_expected.to have_many(:categories).through(:quiz_categories) }
  end

  describe '定数' do
    # 画像アップロードで許可する MIME type の定義を担保する。
    it 'ACCEPTED_CONTENT_TYPES が想定どおりであること' do
      expect(described_class::ACCEPTED_CONTENT_TYPES).to contain_exactly(
        'image/jpeg',
        'image/png',
        'image/gif',
        'image/webp'
      )
    end
  end
end
