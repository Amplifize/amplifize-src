class Feed < ActiveRecord::Base
  has_many :posts
  has_many :tags
  
  has_and_belongs_to_many :users
  
  validates_uniqueness_of :url
  
  before_save :setup_feed_metadata
   
  def self.update_feeds
    Delayed::Job.enqueue(FeedsJob.new)
  end
  
  
  def self.check_feed_url(url)
    if url[0..3] == "feed"
      url = "http" + url[4..-1]
    elsif url["://"].nil?
      url = "http://" + url
    end
    
    url
  end

  private
  def setup_feed_metadata
    if self.title.nil?
      feed = Feedzirra::Feed.fetch_and_parse(self.url)
      if feed.nil? or feed.is_a? Fixnum then
        return false
      else
        self.title = feed.title  
      end
    end
  end
end
