class Share < ActiveRecord::Base
  has_many :comments
  
  belongs_to :user
  belongs_to :post
  
  scope :desc, order("shares.created_at DESC")
end
