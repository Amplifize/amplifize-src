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
    if url[0,1] == "@"
      twitter_user_id = TwitterWrapper.get_user_id_for_screen_name(url[1..-1])
      if twitter_user_id.nil?
        return nil
      end
      url = "twitter://#{twitter_user_id}"
    elsif url[0..3] == "feed"
      url = "http" + url[4..-1]
    elsif url["://"].nil?
      url = "http://" + url
    end
    url
  end

  def self.get_feed_type_for_url(url)
    if url.start_with?("twitter")
    return 2
    end
    return 1
  end

  private

  def setup_feed_metadata
    self.url = Feed.check_feed_url(self.url)
    self.feed_type = Feed.get_feed_type_for_url(self.url)

    # if self.feed_type == 1
      # if self.title.nil?
        # #feed = Feedzirra::Feed.fetch_and_parse(self.url)
        # if feed.nil? or feed.is_a? Fixnum then
        # return false
        # else
        # self.title = feed.title
        # end
      # end
    # end
  end
end
