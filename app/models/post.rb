class Post < ActiveRecord::Base
  belongs_to :feed

  has_many :post_users
  has_many :users, :through => :post_users

  after_create :attach_to_users

  scope :desc, order("posts.published_at ASC")
  
  scope :unread, lambda {
    where("post_users.read_state = 1")
  }

  def self.get_new_posts(feed_url, feed_id, last_update_date)
    options = last_update_date.nil? ? {} : {:if_modified_since => last_update_date}
    feed = Feedzirra::Feed.fetch_and_parse(feed_url, options)

    if not feed.nil? and not feed.is_a? Fixnum then 
      add_entries(feed.entries, feed_id)
    end
  end

  def self.synchronize_posts_with_users(user_id, feed_id)
    posts = Post.find_all_by_feed_id(feed_id, :limit => 10)
    
    begin
      posts.each do |post|
        PostUser.create(
          :post_id      => post.id,
          :user_id      => user_id,
          :read_state   => 1
        )
      end
    rescue ActiveRecord::StatementInvalid => e
      raise e unless /Mysql2::Error: Duplicate entry/.match(e)
    end

    return posts
  end

  private

  def self.add_entries(entries, feed_id)
    entries.each do |entry|
      begin
        unless exists? :uid => entry.id
          create!(
            :title        => entry.title.html_safe,
            :content      => entry.content.nil? ? entry.summary.html_safe : entry.content.html_safe,
            :url          => entry.url,
            :published_at => entry.published,
            :uid          => entry.id,
            :feed_id      => feed_id
          )
        end
      rescue
        next
      end
    end
  end

  def attach_to_users
    feed = Feed.find_by_id(self.feed_id)
    feed.users.each do |user|
      begin
        PostUser.create(
          :post_id      => self.id,
          :user_id      => user.id,
          :read_state   => 1
        )
      rescue ActiveRecord::StatementInvalid => e
        raise e unless /Mysql2::Error: Duplicate entry/.match(e)
      end
    end
  end
end
