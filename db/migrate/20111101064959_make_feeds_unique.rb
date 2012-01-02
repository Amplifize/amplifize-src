class MakeFeedsUnique < ActiveRecord::Migration
  def self.up
    add_index :feeds, :url, :unique => true
  end

  def self.down
  end
end
