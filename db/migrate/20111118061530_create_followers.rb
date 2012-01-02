class CreateFollowers < ActiveRecord::Migration
  def self.up
    create_table :followers do |t|
      t.integer :user_id
      t.integer :follow_id

      t.timestamps
    end
    
    add_foreign_key :followers, :users, :column => 'user_id'
    add_foreign_key :followers, :users, :column => 'follow_id'
    
  end

  def self.down
    drop_table :followers
  end
end
