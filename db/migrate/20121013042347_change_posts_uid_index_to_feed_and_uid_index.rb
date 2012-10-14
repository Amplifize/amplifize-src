class ChangePostsUidIndexToFeedAndUidIndex < ActiveRecord::Migration
  def self.up
    remove_index :posts, :column => :uid
    add_index :posts, [:feed_id,:uid], :unique => true
  end

  def self.down
    remove_index :posts, :column => [:feed_id,:uid]
    #add_index :posts, :uid, :unique => true
  end
end
