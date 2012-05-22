class AddIndexFeedsUsers < ActiveRecord::Migration
  def self.up
    add_index :feeds_users, [:feed_id, :user_id], :unique => true
  end

  def self.down
    remove_index :feeds_users, :column => [:feed_id, :user_id]
  end
end
