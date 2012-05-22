class AddForeignIndexOnPosts < ActiveRecord::Migration
  def self.up
    add_column :posts, :feed_id, :integer
    add_foreign_key :posts, :feeds
  end

  def self.down
    remove_column :posts, :feed_id
    drop_foreign_key :posts, :feeds
  end
end
