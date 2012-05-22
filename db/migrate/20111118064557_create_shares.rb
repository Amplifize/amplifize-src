class CreateShares < ActiveRecord::Migration
  def self.up
    create_table :shares do |t|
      t.text :summary
      t.references :user
      t.references :post

      t.timestamps
    end
  end

  def self.down
    drop_table :shares
  end
end
