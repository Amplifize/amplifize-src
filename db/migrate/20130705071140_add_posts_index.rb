class AddPostsIndex < ActiveRecord::Migration
  def up
    add_index :posts, :published_at, :name => 'publishedat_index'
  end

  def down
    remove_index :posts, 'publishedat_index'
  end
end
