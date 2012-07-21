class CreateInvites < ActiveRecord::Migration
  def self.up
    create_table :invites do |t|
      t.string :uid
      t.string :email
      t.text :message
      t.references :user
      t.timestamps
    end
    add_index :invites, [:uid], :unique => true
  end

  def self.down
    remove_index :invites, :column => [:uid]
    drop_table :invites
  end
end
