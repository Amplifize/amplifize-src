class ShareUser < ActiveRecord::Base
  # read_state status codes are as follows:
  # => 0 == read
  # => 1 == unread

  belongs_to :share
  belongs_to :user
end
