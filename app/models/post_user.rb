class PostUser < ActiveRecord::Base
  # read_state status codes are as follows:
  # => 0 == read
  # => 1 == unread

  attr_accessible :post_id, :user_id, :read_state

  belongs_to :post
  belongs_to :user
  
  scope :oldest_to_newest, order("posts.published_at ASC")
  scope :newest_to_oldest, order("posts.published_at DESC")

  scope :unread, lambda {
    where("post_users.read_state = 1")
  }

  scope :rolling_window, lambda {
    where("posts.published_at > '" + (DateTime.now << 2).to_s(:db) + "'")
  }

end
