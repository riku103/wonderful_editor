class Api::V1::ArticlesController < Api::V1::BaseApiController
  before_action :login_check, except: [:index, :show]
  before_action :authenticate_user!, except: [:index, :show]

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

  def update
    # 対象のレコード(ログインしたユーザーが作成した記事)を探す
    article = current_user.articles.find(params[:id])
    # 探してきたレコードに対して変更を行う
    article.update!(article_params)
    # jsonとして値を返す
    render json: article
  end

  def destroy
    article = current_user.articles.find(params[:id])
    article.destroy!
  end

  private

    def article_params
      params.require(:article).permit(:title, :body).merge(user_id: current_user.id)
    end

    def login_check
      unless user_signed_in?
        redirect_to root_path
      end
    end
end
