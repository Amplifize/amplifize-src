class Post < ActiveRecord::Base
  belongs_to :feed

  has_many :posts_users
  has_many :users, :through => :posts_users
end
