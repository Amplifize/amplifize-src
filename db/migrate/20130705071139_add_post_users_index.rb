class AddPostUsersIndex < ActiveRecord::Migration
  def up
    add_index :post_users, [:post_id, :user_id], :name => 'posts_users_index'
    add_index :post_users, :read_state, :name => 'readstate_index'
  end

  def down
    remove_index :post_users, 'posts_users_index'
    remove_index :post_users, 'readstate_index'
  end
end
