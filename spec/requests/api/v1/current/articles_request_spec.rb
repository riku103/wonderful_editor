require "rails_helper"

RSpec.describe "Api::V1::Current::Articles", type: :request do
  let(:current_user) { create(:user) }
  let(:headers) { current_user.create_new_auth_token }

  describe "GET /api/v1/current/articles" do
    subject { get(api_v1_current_articles_path, headers: headers) }

    context "複数の記事が存在する時" do
      let!(:article1) { create(:article, updated_at: 1.days.ago, status: "published", user: current_user) }
      let!(:article2) { create(:article, updated_at: 2.days.ago, status: "published", user: current_user) }
      let!(:article3) { create(:article, status: "published", user: current_user) }
      let!(:article4) { create(:article, status: "published") }
      it "自分の書いた公開記事を更新順に取得できる" do
        subject

        res = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(res.length).to eq 3
        expect(res.map {|d| d["id"] }).to eq [article3.id, article1.id, article2.id]
        expect(res[0]["user"]["id"]).to eq current_user.id
        expect(res[0]["user"]["name"]).to eq current_user.name
        expect(res[0]["user"]["email"]).to eq current_user.email
      end
    end
  end
end
