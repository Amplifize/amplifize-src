class CreateShareUsers < ActiveRecord::Migration
  def self.up
    create_table :share_users do |t|
      t.references :share
      t.references :user
      t.integer :read_state
      
      t.timestamps
    end
  end

  def self.down
    drop_table :share_users
  end
end
