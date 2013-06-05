class AddLastViewLastUpdateColumnsToShareUsers < ActiveRecord::Migration
  def change
    add_column :share_users, :last_updated_at, :datetime
    add_column :share_users, :last_viewed_at, :datetime
  end
end
