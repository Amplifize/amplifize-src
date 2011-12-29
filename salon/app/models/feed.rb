class Feed < ActiveRecord::Base
  has_many :posts
  
  has_and_belongs_to_many :users
  
  validates_uniqueness_of :url
  
  before_save :check_feed_url, :setup_feed_metadata
   
  def self.update_feeds
    feeds = Feed.all
    feeds.each { |feed|
      Post.get_new_posts(feed.url, feed.id)
    }
    
    puts "Finished updating feeds"
  end
  
  @private
  def check_feed_url
    if self.url[0..3] == "feed"
      self.url = "http" + self.url[4..-1]
    end
  end

  def setup_feed_metadata
    feed = Feedzirra::Feed.fetch_and_parse(self.url)
    self.title = feed.title
  end
end
