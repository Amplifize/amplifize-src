class AddTagsIndexOnName < ActiveRecord::Migration
  def up
    add_index :tags, :name, :name => 'name_index'
  end

  def down
    remove_index :tags, 'name_index'
  end
end
