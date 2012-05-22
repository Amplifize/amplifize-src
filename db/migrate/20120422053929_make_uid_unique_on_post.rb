class MakeUidUniqueOnPost < ActiveRecord::Migration
  def self.up
    add_index :posts, :uid, :unique => true
  end

  def self.down
    remove_index :posts, :column => :uid
  end
end
