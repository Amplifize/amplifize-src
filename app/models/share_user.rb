class ShareUser < ActiveRecord::Base
  # read_state status codes are as follows:
  # => 0 == read
  # => 1 == unread

  belongs_to :share
  belongs_to :user

  scope :oldest_to_newest, order("shares.created_at ASC")
  scope :newest_to_oldest, order("shares.created_at DESC")
  
  scope :unread, lambda {
    where("share_users.read_state = 1")
  }

  scope :rolling_window, lambda {
    where("shares.created_at > '" + (DateTime.now << 2).to_s(:db) + "'")
  }

end
