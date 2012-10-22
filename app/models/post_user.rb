class PostUser < ActiveRecord::Base
  # read_state status codes are as follows:
  # => 0 == read
  # => 1 == unread

  belongs_to :post
  belongs_to :user
  
  scope :oldest_to_newest, order("post_users.created_at ASC")
  scope :newest_to_oldest, order("post_users.created_at DESC")

  scope :unread, lambda {
    where("post_users.read_state = 1")
  }

  scope :rolling_window, lambda {
    where("post_users.created_at > '" + (DateTime.now << 2).to_s(:db) + "'")
  }

end
