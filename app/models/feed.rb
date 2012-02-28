class Feed < ActiveRecord::Base
  has_many :posts
  
  has_and_belongs_to_many :users
  
  validates_uniqueness_of :url
  
  before_save :check_feed_url, :setup_feed_metadata
   
  def self.update_feeds
    Delayed::Job.enqueue(FeedsJob.new)
  end
  
  @private
  def check_feed_url
    if self.url[0..3] == "feed"
      self.url = "http" + self.url[4..-1]
    end
  end

  def setup_feed_metadata
    feed = Feedzirra::Feed.fetch_and_parse(self.url)
    if feed.nil? or feed.is_a? Fixnum then
      return false
    else
      self.title = feed.title  
    end
  end
end
