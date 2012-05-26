class Share < ActiveRecord::Base
  has_many :comments
  
  belongs_to :user
  belongs_to :post
  
  scope :desc, order("shares.created_at DESC")
  
  scope :unread, lambda {
    where("share_users.read_state = 1")
  }

end
