class Article < ApplicationRecord
  belongs_to :user
  has_many :article_likes, dependent: :destroy
  has_many :comments, dependent: :destroy

  validates :title, :user, presence: true
  validates :body, length: { minimum: 10 }
end
