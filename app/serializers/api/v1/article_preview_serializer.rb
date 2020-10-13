class Api::V1::ArticlePreviewSerializer < ActiveModel::Serializer
  attributes :id, :title, :updated_at, :status
  belongs_to :user, serializer: Api::V1::UserSerializer
end
