class ChangeFollowsColumnName < ActiveRecord::Migration
  def self.up
    rename_column :follows, :follower, :user_id
    rename_column :follows, :followed, :follows
    add_foreign_key :follows, :users
  end

  def self.down
  end
end
