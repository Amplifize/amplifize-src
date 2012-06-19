class User < ActiveRecord::Base
  acts_as_authentic do |c| 
     c.login_field = :email 
  end
  
  has_and_belongs_to_many :feeds
  
  has_many :follows
  has_many :post_users
  has_many :posts, :through => :post_users
  
  has_many :share_users
  has_many :shares, :through => :share_users
  
  has_many :tags
  
  def shares_unread_count
    shares.unread.count
  end
  
  def feeds_unread_count
    posts.unread.rolling_window.count
  end
  
  def feeds_with_unread
    user_feeds = feeds
    counts = PostUser.joins(:post => [:feed]).where(:user_id => id, :read_state => 1).group(:feed_id).count
    
    user_feeds.each { |feed|
      if not counts[feed.id].nil?
        feed.unread = counts[feed.id]
      else
        feed.unread = 0
      end
      
      user_feeds
    }
  end
end
