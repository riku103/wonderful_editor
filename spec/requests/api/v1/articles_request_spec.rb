require "rails_helper"

RSpec.describe "Api::V1::Articles", type: :request do
  describe "GET /articles" do
    subject { get(api_v1_articles_path) }

    # let!(:user) { create(:user) }
    let!(:article1) { create(:article, updated_at: 1.days.ago) }
    let!(:article2) { create(:article, updated_at: 2.days.ago) }
    let!(:article3) { create(:article) }
    it "記事一覧を取得できる" do
      subject
      res = JSON.parse(response.body)

      # ①記事一覧が取得できる
      expect(res.length).to eq 3
      # ②帰ってきた記事の一覧にbody が含まれていないこと
      expect(res[0].keys).to eq ["id", "title", "updated_at", "user"]
      # ③記事が更新順に取得できること
      expect(res.map {|d| d["id"] }).to eq [article3.id, article1.id, article2.id]
      # ④ステータスコードが200であること
      expect(response).to have_http_status(:success)
      # ⑤誰が書いた記事が取得できる
      expect(res[0]["user"].keys).to eq ["id", "name", "email"]
    end
  end
end
