require "rails_helper"

RSpec.describe Article, type: :model do
  context "必要な情報が入力されているとき" do
    it "記事が登録できる" do
      user = create(:user)
      article = build(:article, user_id: user.id)
      expect(article).to be_valid
    end
  end

  context "title がない場合" do
    it "エラーが発生する" do
      user = create(:user)
      article = build(:article, title: nil, user_id: user.id)
      expect(article).not_to be_valid
      expect(article.errors.details[:title][0][:error]).to eq :blank
    end
  end

  context "ユーザー登録していない場合" do
    it "エラーが発生する" do
      article = build(:article)
      expect(article).not_to be_valid
    end
  end

  context "body が10文字以下の場合" do
    fit "エラーが発生する" do
      user = create(:user)
      article = build(:article, body: "テスト", user_id: user.id)
      expect(article).not_to be_valid
    end
  end
end
