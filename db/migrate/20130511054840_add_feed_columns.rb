class AddFeedColumns < ActiveRecord::Migration
  def up
    add_column :feeds, :description, :text
    add_column :feeds, :site_url, :text
  end

  def self.down
    remove_column :feeds, :description
    remove_column :feeds, :site_url
  end
end
