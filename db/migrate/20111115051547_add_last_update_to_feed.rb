class AddLastUpdateToFeed < ActiveRecord::Migration
  def self.up
    add_column :feeds, :last_update_date, :datetime
  end

  def self.down
    remove_column :feeds, :last_update_date
  end
end
