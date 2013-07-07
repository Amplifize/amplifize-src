class AddShareUsersIndex < ActiveRecord::Migration
  def up
    add_index :share_users, :user_id, :name => 'userid_index'
    add_index :share_users, :read_state, :name => 'readstate_index'
  end

  def down
    remove_index :share_users, 'userid_index'
    remove_index :share_users, 'readstate_index'
  end
end
