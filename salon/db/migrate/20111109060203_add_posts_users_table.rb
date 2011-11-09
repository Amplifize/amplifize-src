class AddPostsUsersTable < ActiveRecord::Migration
  def self.up
    create_table :posts_users do |t|
      t.references :post
      t.references :user
      t.integer :read_state

      t.timestamps      
    end
    
    add_foreign_key :posts_users, :users
    add_foreign_key :posts_users, :posts
  end

  def self.down
    drop_table :posts_users
  end
end
