class AddPostUsersTable < ActiveRecord::Migration
  def self.up
    create_table :post_users do |t|
      t.integer :post_id
      t.integer :user_id
      t.integer :read_state

      t.timestamps      
    end
    
    add_foreign_key :post_users, :users
    add_foreign_key :post_users, :posts
  end

  def self.down
    drop_table :post_users
  end
end
