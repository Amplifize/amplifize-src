class PostUser < ActiveRecord::Base
  # read_state status codes are as follows:
  # => 0 == read
  # => 1 == unread

  belongs_to :post
  belongs_to :user
end
