class Comment < ActiveRecord::Base
  attr_accessible :share_id, :user_id, :comment_text

  belongs_to :share
  belongs_to :user

end
