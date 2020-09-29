class Api::V1::ArticlesController < Api::V1::BaseApiController
  # 下記の記述で記事を作成できるのは、ログインしているユーザーのみになる
  # テストの実装では必要ないのでコメントアウト
  # before_action :authenticate_user!, only: [:create]

  def index
    articles = Article.order(updated_at: :desc)
    render json: articles, each_serializer: Api::V1::ArticlePreviewSerializer
  end

  def show
    article = Article.find(params[:id])
    render json: article
  end

  def create
    article = current_user.articles.create!(article_params)
    render json: article
  end

  private

    def article_params
      params.require(:article).permit(:title, :body).merge(user_id: current_user.id)
    end
end
