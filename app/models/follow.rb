class Follow < ActiveRecord::Base
  belongs_to :follower, :class_name => "User", :foreign_key => "follower"
  belongs_to :followed, :class_name => "User", :foreign_key => "followed"
end
