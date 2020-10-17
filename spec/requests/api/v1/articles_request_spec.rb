require "rails_helper"

RSpec.describe "Api::V1::Articles", type: :request do
  describe "GET /articles" do
    subject { get(api_v1_articles_path) }

    context "公開状態で作成された記事について" do
      let!(:article1) { create(:article, updated_at: 1.days.ago, status: "published") }
      let!(:article2) { create(:article, updated_at: 2.days.ago, status: "published") }
      let!(:article3) { create(:article, status: "published") }
      let!(:article4) { create(:article) }

      it "一覧を取得できる" do
        subject
        res = JSON.parse(response.body)

        # ①公開状態で作成された記事一覧だけが取得できる
        expect(res.length).to eq 3
        # ②帰ってきた記事の一覧にbody が含まれていないこと
        expect(res[0].keys).to eq ["id", "title", "updated_at", "status", "user"]
        # ③記事が更新順に取得できること
        expect(res.map {|d| d["id"] }).to eq [article3.id, article1.id, article2.id]
        # ④ステータスコードが200であること
        expect(response).to have_http_status(:ok)
        # ⑤誰が書いた記事が取得できるか
        expect(res[0]["user"].keys).to eq ["id", "name", "email"]
      end
    end
  end

  describe "GET /articles/:id" do
    subject { get(api_v1_article_path(article_id)) }

    context "指定したid の記事が存在して" do
      let(:article_id) { article.id }
      context "対象の記事が公開中である時" do
        let(:article) { create(:article, status: "published") }

        it "その記事の詳細が取得できる" do
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

      context "対象の記事が下書き状態の時" do
        let(:article) { create(:article) }
        it "記事を取得できない" do
          expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
        end
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
    subject { post(api_v1_articles_path, params: params, headers: headers) }

    context "ログインしているユーザーが" do
      let(:current_user) { create(:user) }
      let(:headers) { current_user.create_new_auth_token }

      context "下書き状態で送信した記事" do
        let(:params) do
          { article: attributes_for(:article, status: "draft") }
        end

        it "下書き記事が作成できる" do
          expect { subject }.to change { Article.count }.by(1)
          res = JSON.parse(response.body)
          expect(res["status"]).to eq "draft"
          expect(response).to have_http_status(:ok)
        end
      end

      context "公開状態で送信した記事" do
        let(:params) do
          { article: attributes_for(:article, status: "published") }
        end

        it "記事を作成できる" do
          # ①レコードが一つ作成できること
          expect { subject }.to change { Article.where(user_id: current_user.id).count }.by(1)
          expect(response).to have_http_status(:ok)
          # ②送ったパラメーターを元にレコードが作成されていること
          res = JSON.parse(response.body)
          expect(res["title"]).to eq params[:article][:title]
          expect(res["body"]).to eq params[:article][:body]

          # ③ログインしたユーザーが送ったパラメーターか確認する
          header = response.headers
          expect(header["access-token"]).to eq headers["access-token"]
          expect(header["client"]).to eq headers["client"]
          expect(header["uid"]).to eq headers["uid"]
        end
      end

      context "でたらめな指定で記事を作成する時" do
        let(:params) do
          { article: attributes_for(:article, status: "foo") }
        end
        it "エラーになる" do
          expect { subject }.to raise_error(ArgumentError)
        end
      end
    end
  end

  describe "PUT /articles/:id" do
    subject { put(api_v1_article_path(article.id), params: params, headers: headers) }

    let(:params) do
      { article: attributes_for(:article, status: "published") }
    end

    let(:current_user) { create(:user) }
    let(:headers) { current_user.create_new_auth_token }

    context "自分の作成した記事を更新しようとするとき" do
      let!(:article) { create(:article, status: "draft", user: current_user) }

      # ①送信した値のみ書き換えられていること
      it "任意の記事の内容を更新できる" do
        expect { subject }.to change { article.reload.title }.from(article.title).to(params[:article][:title]) &
                              change { article.reload.body }.from(article.body).to(params[:article][:body]) &
                              change { article.reload.status }.from(article.status).to(params[:article][:status])
        expect(response).to have_http_status(:ok)
      end
    end

    context "自分が作成していない記事のレコードを更新しようとするとき" do
      let(:other_user) { create(:user) }
      let!(:article) { create(:article, user: other_user) }

      it "更新できない" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound) &
                              change { Article.count }.by(0)
      end
    end
  end

  describe "DELETE /articles/:id" do
    subject { delete(api_v1_article_path(article_id), headers: headers) }

    let(:current_user) { create(:user) }
    let(:headers) { current_user.create_new_auth_token }
    let(:article_id) { article.id }

    context "自分の記事を削除しようとするとき" do
      let!(:article) { create(:article, user: current_user) }

      it "記事を削除できる" do
        expect { subject }.to change { Article.count }.by(-1)
        # httpステータスコードは204を返す
        expect(response).to have_http_status(:no_content)
      end
    end

    context "自分の作成していない記事を削除しようとするとき" do
      let(:other_user) { create(:user) }
      let!(:article) { create(:article, user: other_user) }
      it "削除できない" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound) &
                              change { Article.count }.by(0)
      end
    end
  end
end
