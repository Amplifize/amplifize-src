class AddSharesUsersIndex < ActiveRecord::Migration
  def up
    add_index :share_users, [:share_id, :user_id], :name => 'shares_users_index'
  end

  def down
    remove_index :share_users, 'shares_users_index'
  end
end
