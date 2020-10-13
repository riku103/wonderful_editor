require "rails_helper"

RSpec.describe User, type: :model do
  context "必要な情報が揃っている場合" do
    let(:user) { build(:user) }
    it "ユーザー登録できる" do
      # user = FactoryBot.build(:user)
      # expext(user.valid?).to eq true
      expect(user).to be_valid
    end
  end

  context "名前のみ入力している場合" do
    let(:user) { build(:user, email: nil, password: nil) }
    it "エラーが発生する" do
      expect(user).not_to be_valid
      expect(user.errors.details[:password][0][:error]).to eq :blank
      expect(user.errors.details[:email][0][:error]).to eq :blank
    end
  end

  context "email がない場合" do
    let(:user) { build(:user, email: nil) }
    it "エラーが発生する" do
      expect(user).not_to be_valid
      expect(user.errors.details[:email][0][:error]).to eq :blank
    end
  end

  context "password がない場合" do
    let(:user) { build(:user, password: nil) }
    it "エラーが発生する" do
      expect(user).not_to be_valid
      expect(user.errors.details[:password][0][:error]).to eq :blank
    end
  end

end
