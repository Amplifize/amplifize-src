class AddFollowsIndex < ActiveRecord::Migration
  def up
    add_index :follows, [:user_id, :follows], :name => 'follows_index'
  end

  def down
    remove_index :follows, 'follows_index'
  end
end
