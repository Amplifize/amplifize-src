class CreateRssFeedsUsers < ActiveRecord::Migration
  def self.up
    create_table :rssfeeds_users, :id => false do |t|
      t.references :rss_feed
      t.references :user

      t.timestamps
    end
  end

  def self.down
    drop_table :rssfeeds_users
  end
end
