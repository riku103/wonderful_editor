require "rails_helper"

RSpec.describe "Api::V1::Auth::Sessions", type: :request do
  describe "POST /api/v1/auth/sign_in" do
    subject { post(api_v1_user_session_path, params: params) }

    context "登録済みのユーザー情報を送信したとき" do
      let(:user) { create(:user) }
      let(:params) { attributes_for(:user, email: user.email, password: user.password) }

      it "ログインできる" do
        subject
        expect(response).to have_http_status(:ok)

        header = response.header
        expect(header["access-token"]).to be_present
        expect(header["client"]).to be_present
        expect(header["uid"]).to be_present
      end
    end

    context "email が違うとき" do
      let(:user) { create(:user) }
      let(:params) { attributes_for(:user, password: user.password) }

      it "ログインに失敗する" do
        subject
        res = JSON.parse(response.body)
        expect(res["errors"]).to include "Invalid login credentials. Please try again."
        header = response.header
        expect(header["access-token"]).to be_blank
        expect(header["client"]).to be_blank
        expect(headers["uid"]).to be_blank
        # 401エラーを返す
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "password が違うとき" do
      let(:user) { create(:user) }
      let(:params) { attributes_for(:user, email: user.email) }

      it "ログインに失敗する" do
        subject
        res = JSON.parse(response.body)
        expect(res["errors"]).to include "Invalid login credentials. Please try again."
        header = response.header
        expect(header["access-token"]).to be_blank
        expect(header["client"]).to be_blank
        expect(headers["uid"]).to be_blank
        # 401エラーを返す
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
