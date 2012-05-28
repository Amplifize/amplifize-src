class CreateFeedStatuses < ActiveRecord::Migration
  def self.up
    create_table :feed_statuses do |t|
      t.references :feed
      t.string :url
      t.integer :status_code
      t.integer :response_code
      t.text :message
      t.datetime :update_time
    end
    
    add_index :feed_statuses, [:feed_id], :unique => false
  end

  def self.down
    remove_index :feed_statuses, :column => [:feed_id]
    
    drop_table :feed_statuses
  end
end
