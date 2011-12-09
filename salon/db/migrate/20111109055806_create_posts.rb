class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.string :title
      t.string :url
      t.datetime :written_dt
      t.text :content, :limit => 4294967295

      t.timestamps
    end
  end

  def self.down
    drop_table :posts
  end
end
