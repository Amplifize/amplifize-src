class User < ActiveRecord::Base
  attr_accessible :email, :password, :password_confirmation
  
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
    share_users.joins(:share).unread.count
  end

  def share_unread_count(follower_id)
    share_users.joins(:share).where("shares.user_id = ?", follower_id).unread.count
  end
  
  def feeds_unread_count
    post_users.joins(:post).unread.rolling_window.count
  end

  def feed_unread_count(feed_id)
    post_users.joins(:post).where("posts.feed_id = ?", feed_id).unread.rolling_window.count    
  end
  
  def visible_name
    display_name.nil? ? email : display_name
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
  
  def single_access_token
    sat = read_attribute(:single_access_token)
    if sat.nil? or sat.empty? 
      reset_single_access_token!
      sat = read_attribute(:single_access_token)
    end
    sat
  end

  def deliver_password_reset_instructions!  
    reset_perishable_token!  
    Mailer.delay.forgot_password_email(self)  
  end  

end
