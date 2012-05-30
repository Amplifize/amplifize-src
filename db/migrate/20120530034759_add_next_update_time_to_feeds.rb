class AddNextUpdateTimeToFeeds < ActiveRecord::Migration
  def self.up
    add_column :feeds, :next_update_at, :datetime, :default => 0
  end

  def self.down
    remove_column :feeds, :next_update_at
  end
end
