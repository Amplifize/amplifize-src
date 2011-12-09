class User < ActiveRecord::Base
  acts_as_authentic do |c| 
     c.login_field = :email 
  end
  
  has_and_belongs_to_many :feeds

  has_many :post_users
  has_many :posts, :through => :post_users
  
  has_many :shares

end
