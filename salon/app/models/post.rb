class Post < ActiveRecord::Base
  belongs_to :feed

  has_many :post_users
  has_many :users, :through => :post_users
end
