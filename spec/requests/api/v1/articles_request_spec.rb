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
      expect(response).to have_http_status(:ok)
      # ⑤誰が書いた記事が取得できるか
      expect(res[0]["user"].keys).to eq ["id", "name", "email"]
    end
  end

  describe "GET /articles/:id" do
    subject { get(api_v1_article_path(article_id)) }

    context "指定したidの記事が存在する時" do
      let(:article) { create(:article) }
      let(:article_id) { article.id }
      it "その記事の詳細が取得できる" do
        subject

        res = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(res["id"]).to eq article.id
        expect(res["title"]).to eq article.title
        expect(res["body"]).to eq article.body
        expect(res["updated_at"]).to be_present
        expect(res["user"]["id"]).to eq article.user.id
        expect(res["user"].keys).to eq ["id", "name", "email"]
      end
    end

    context "指定した id の記事が存在しない時" do
      let(:article_id) { 100000 }
      it "記事が見つからない" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "POST /articles" do
    subject { post(api_v1_articles_path, params: params) }

    # スタブを定義する
    before { allow_any_instance_of(Api::V1::BaseApiController).to receive(:current_user).and_return(create(:user)) }

    context "適切なパラメーターを送信した時" do
      let(:params) do
        { article: attributes_for(:article) }
      end

      it "記事を作成できる" do
        # ①レコードが一つ作成できること
        expect { subject }.to change { Article.count }.by(1)
        # ②送ったパラメーターを元にレコードが作成されていること
        res = JSON.parse(response.body)
        expect(res["title"]).to eq params[:article][:title]
        expect(res["body"]).to eq params[:article][:body]
        expect(response).to have_http_status(:ok)
      end
    end

    context "不適切なパラメーターを送信した時" do
      let(:params) { attributes_for(:article) }

      it "エラーする" do
        expect { subject }.to raise_error(ActionController::ParameterMissing)
      end
    end
  end
end
