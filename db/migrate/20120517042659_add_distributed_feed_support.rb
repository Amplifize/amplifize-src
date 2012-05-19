class AddDistributedFeedSupport < ActiveRecord::Migration
  def self.up
    add_column :feeds, :status, :integer, :default => 1
  end

  def self.down
    remove_column :feeds, :status
  end
end
