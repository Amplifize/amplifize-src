class Feed < ActiveRecord::Base
  has_many :posts
  
  has_and_belongs_to_many :users
  
  validates_uniqueness_of :url
  
  before_save :check_feed_url
  after_save :get_feed_posts

  def self.update_feeds
    feeds = Feed.all

    feeds.each { |feed|
      options = {:if_modified_since => feed.last_update_date}
      get_new_posts(feed, options)
      
      feed.last_update_date = Time.new
      feed.save
    }
  end
  
  def get_feed_posts
    Feed.get_new_posts(self)
    self.last_update_date = Time.new
  end
  
  @private
  def check_feed_url
    if self.url[0..3] == "feed"
      self.url = "http" + self.url[4..-1]
    end
  end
    
  def self.get_new_posts(feed, options = {})
      posts = Feedzirra::Feed.fetch_and_parse(feed.url, options)

      if not posts == 304
        posts.entries.each { |post|
          new_post = Post.new
          new_post.feed_id = feed.id
          new_post.title = post.title
          new_post.url = post.url
          new_post.written_dt = post.published
          #new_post.created_dt = post.published
          new_post.content = post.content.nil? ? post.summary : post.content
          
          new_post.save
          
          feed.users.each { |user|
            new_post_user = PostUser.new
            new_post_user.post_id = new_post.id
            new_post_user.user_id = user.id
            new_post_user.read_state = 1
            
            new_post_user.save
          }
        }
      end
  end
end
