class Api::V1::Articles::DraftsController < Api::V1::BaseApiController
  before_action :authenticate_user!

  def index
    article = current_user.articles.draft.order(updated_at: :desc)
    render json: article, each_serializer: Api::V1::ArticlePreviewSerializer
  end

  def show
    article = current_user.articles.draft.find(params[:id])
    render json: article, serializer: Api::V1::ArticleSerializer
  end
end
