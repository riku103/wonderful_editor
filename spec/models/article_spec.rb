require "rails_helper"

RSpec.describe Article, type: :model do
  context "必要な情報が入力されているとき" do
    let(:user) { create(:user) }
    let(:article) { build(:article, user_id: user.id) }
    it "記事が登録できる" do
      expect(article).to be_valid
    end
  end

  context "title がない場合" do
    let(:user) { create(:user) }
    let(:article) { build(:article, title: nil, user_id: user.id) }
    it "エラーが発生する" do
      expect(article).not_to be_valid
    end
  end

  context "ユーザー登録していない場合" do
    let(:article) { build(:article) }
    it "エラーが発生する" do
      expect(article).not_to be_valid
    end
  end

  context "body が10文字以下の場合" do
    let(:user) { create(:user) }
    let(:article) { build(:article, body: "テスト", user_id: user.id) }
    it "エラーが発生する" do
      expect(article).not_to be_valid
    end
  end
end
