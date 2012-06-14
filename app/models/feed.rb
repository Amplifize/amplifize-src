###
# Feeds
#
# Feed.feed_type Constants:
#  * 1 - RSS/ATOM over HTTP
#  * 2 - Twitter 
#
# Feed.status Constants:
#  * 1 - Feed is Normal
#  * 2 - Feed is new, not yet updated/initialized
#  * >3 - Feed error, actual meanings tbd
###

class Feed < ActiveRecord::Base
  
  FEED_DEFAULT_UPDATE_INTERVAL = 15 # minutes
  
  # Feed.status Constants
  FEED_STATUS_OK = 1
  FEED_STATUS_NEW = 2
  FEED_STATUS_ERROR = 3
  
  # Feed.feed_type Constants
  FEED_TYPE_RSS = 1
  FEED_TYPE_TWITTER = 2
  
  
  has_many :posts
  has_many :tags

  has_and_belongs_to_many :users

  validates_uniqueness_of :url

  before_save :setup_feed_metadata
  
  scope :to_update, lambda {
    where("feeds.next_update_at <= '" + DateTime.now.to_s(:db) + "' or feeds.next_update_at IS NULL")
  }

  scope :alphabetical, order("feeds.title ASC")

  # Gets transient attribute for unread count
  def unread
    read_attribute(:unread)
  end
  
  # Sets transient attribute for unread count
  def unread=(value)
    write_attribute(:unread, value)
  end

  def self.update_feeds
    FeedsJob.new.perform
  end

  def self.check_feed_url(url)  
    #if url[0,1] == "@"
      #twitter_user_id = TwitterWrapper.get_user_id_for_screen_name(url[1..-1])
      #if twitter_user_id.nil?
      #  return nil
      #end
      #url = "twitter://#{twitter_user_id}"
    #elsif url[0..3] == "feed"
    if url[0..3] == "feed"
      url = "http" + url[4..-1]
    elsif url["://"].nil?
      url = "http://" + url
    end
    url
  end

  def self.get_feed_type_for_url(url)
    #if url.start_with?("twitter")
    #  return FEED_TYPE_TWITTER
    #end
    return FEED_TYPE_RSS
  end
  
  # Calculate and store adaptive next-update-time for the feed
  # TODO Use feed's average post interval to determine feed update interval
  # TODO Use backoff algorithm for feeds that are in an error state
  # TODO Reduce update interval for feeds that have no subscribers
  def calculate_next_update
    self.next_update_at = (FEED_DEFAULT_UPDATE_INTERVAL.minutes.since DateTime.now).to_s(:db)
    next_update_at
  end

  private

  def setup_feed_metadata
    self.url = Feed.check_feed_url(self.url)
    self.feed_type = Feed.get_feed_type_for_url(self.url)

    # if self.feed_type == FEED_TYPE_RSS
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
