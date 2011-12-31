class Post < ActiveRecord::Base
  belongs_to :feed

  has_many :post_users
  has_many :users, :through => :post_users

  after_save :attach_to_users

  def self.get_new_posts(feed_url, feed_id)
    feed = Feedzirra::Feed.fetch_and_parse(feed_url)
    add_entries(feed.entries, feed_id)
  end

  def self.synchronize_posts_with_users(user_id, feed_id)
    posts = Post.find_all_by_feed_id(feed_id, :limit => 10)
    
    posts.each do |post| 
      PostUser.create(
        :post_id      => post.id,
        :user_id      => user_id,
        :read_state   => 1
      )
    end
    
    return posts
  end

  @private
  def self.add_entries(entries, feed_id)
    entries.each do |entry|
      unless exists? :uid => entry.id
        create!(
          :title        => entry.title.html_safe,
          :content      => entry.content.nil? ? entry.summary : entry.content,
          :url          => entry.url,
          :published_at => entry.published,
          :uid          => entry.id,
          :feed_id      => feed_id
        )
      end
    end
  end
  
  def attach_to_users
    feed = Feed.find_by_id(self.feed_id)
    feed.users.each do |user|
      PostUser.create(
        :post_id      => self.id,
        :user_id      => user.id,
        :read_state   => 1
      )
    end
  end
end
