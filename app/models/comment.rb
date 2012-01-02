class Comment < ActiveRecord::Base
  belongs_to :share, :user

end
