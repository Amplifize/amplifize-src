class User < ActiveRecord::Base
  acts_as_authentic do |c| 
     c.login_field = :email 
  end
  
  has_many :rssfeeds do
    def find_or_create_by_url(url)
      find_or_create_by_url(url)
    end
  end
end
