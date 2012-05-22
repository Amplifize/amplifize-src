class AddTwitterSupport < ActiveRecord::Migration
  def self.up
     create_table :twitter_posts do |t|
      t.string :tweet_id
      t.string :text
      t.string :expanded_url
      t.string :twitter_user_id
      t.timestamp
      t.references :feed
      t.references :post
    end
    add_index :twitter_posts, [:tweet_id], :unique => true
    add_column :feeds, :feed_type, :integer, :default => 1
  end

  def self.down
     remove_column :feeds, :feed_type
     drop_table :twitter_posts
  end
end
