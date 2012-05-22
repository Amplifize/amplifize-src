class AddIndexPostUser < ActiveRecord::Migration
  def self.up
    add_index :post_users, [:post_id, :user_id], :unique => true
  end

  def self.down
    remove_index :post_users, :column => [:post_id, :user_id]
  end
end
