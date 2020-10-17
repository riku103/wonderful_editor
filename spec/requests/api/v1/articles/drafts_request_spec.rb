require "rails_helper"

RSpec.describe "Api::V1::Articles::Drafts", type: :request do
  let(:current_user) { create(:user) }
  let(:headers) { current_user.create_new_auth_token }

  describe "GET /api/v1/articles/drafts" do
    subject { get(api_v1_articles_drafts_path, headers: headers) }

    context "ログインしたユーザーが書いた下書き記事について" do
      let!(:article1) { create(:article, user: current_user) }
      let!(:article2) { create(:article, user: current_user) }
      let!(:article3) { create(:article) }

      it "一覧を取得できる" do
        subject
        res = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(res.length).to eq 2
        expect(res[0]["id"]).to eq article2.id
        expect(res[0].keys).to eq ["id", "title", "updated_at", "status", "user"]
        expect(res[0]["user"].keys).to eq ["id", "name", "email"]
      end
    end

    # context "ログイン情報がないとき" do
    #   let!(:article1) { create(:article) }
    #   fit "下書き一覧を取得できない" do
    #     binding.pry
    #     subject
    #   end
    # end
  end

  describe "GET /api/v1/articles/drafts/:id" do
    subject { get(api_v1_articles_draft_path(article_id), headers: headers) }

    context "指定したid の記事が存在して" do
      let(:article_id) { article.id }
      context "対象の記事が下書き中でログインしたユーザーの時" do
        let(:article) { create(:article, user: current_user) }
        it "記事を取得できる" do
          subject
          res = JSON.parse(response.body)

          expect(response).to have_http_status(:ok)
          expect(res["id"]).to eq article.id
          expect(res["title"]).to eq article.title
          expect(res["body"]).to eq article.body
          expect(res["status"]).to eq article.status
          expect(res["updated_at"]).to be_present
          expect(res["user"]["id"]).to eq article.user.id
          expect(res["user"].keys).to eq ["id", "name", "email"]
        end
      end

      context "対象の記事が他のユーザーの書いた記事なら" do
        let(:article) { create(:article) }
        it "記事が見れない" do
          expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end
end
