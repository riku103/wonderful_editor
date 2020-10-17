class Api::V1::Current::ArticlesController < Api::V1::BaseApiController
  before_action :login_check
  before_action :authenticate_user!

  def index
    article = current_user.articles.published.order(updated_at: :desc)
    render json: article, each_serializer: Api::V1::ArticlePreviewSerializer
  end

  private

    def login_check
      unless user_signed_in?
        redirect_to root_path
      end
    end
end
