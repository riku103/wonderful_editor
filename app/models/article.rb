class Article < ApplicationRecord
  enum status: { draft: 0, published: 1 }

  belongs_to :user
  has_many :article_likes, dependent: :destroy
  has_many :comments, dependent: :destroy

  validates :title, presence: true
  validates :body, length: { minimum: 5 }
end
