class Tag < ActiveRecord::Base
  attr_accessible :user_id, :feed_id, :name

  belongs_to :user
  belongs_to :feed  
end
