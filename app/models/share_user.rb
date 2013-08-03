class ShareUser < ActiveRecord::Base

  READ_STATE = 0
  UNREAD_STATE = 1
  MUTED_STATE = 2

  attr_accessible :share_id, :user_id, :read_state, :last_viewed_at, :last_updated_at

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
