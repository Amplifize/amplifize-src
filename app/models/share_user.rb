class ShareUser < ActiveRecord::Base
  # read_state status codes are as follows:
  # => 0 == read
  # => 1 == unread

  attr_accessible :share_id, :user_id, :read_state

  belongs_to :share
  belongs_to :user

  scope :oldest_to_newest, order("share_users.last_updated_at ASC")
  scope :newest_to_oldest, order("share_users.last_updated_at DESC")
  
  scope :unread, lambda {
    where("share_users.read_state = 1")
  }

  scope :rolling_window, lambda {
    where("shares.created_at > '" + (DateTime.now << 2).to_s(:db) + "'")
  }

end
