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
  FEED_MIN_UPDATE_INTERVAL = 15 # minutes
  FEED_MAX_UPDATE_INTERVAL = 1440 # minutes

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
    #ActiveRecord::Base.logger = Logger.new(STDOUT)

    active_subscriber_count = 1
    update_interval = FEED_MAX_UPDATE_INTERVAL
    begin
    # If the feed has any subscribers, then we want to calculate a more precise update interval
      if active_subscriber_count > 0
        current_sum = 0
        current_count = 0
        historic_sum = 0
        historic_count = 0

        time_since_last_post = -1

        last_time = DateTime.now.utc

        last_ten = posts.last_ten.map { |c| c.published_at.to_datetime }
        last_ten.each do |time|
          #puts "Time: #{time} / Interval #{(last_time.to_i - time.to_i).abs}"
          if current_count > 0
            historic_sum += (last_time.to_i - time.to_i).abs
            historic_count += 1
          else
            time_since_last_post = (last_time.to_i - time.to_i).abs
          end
          current_sum += (last_time.to_i - time.to_i).abs
          current_count += 1
          last_time = time
        end

        current_update_interval = FEED_MAX_UPDATE_INTERVAL
        historic_update_interval = FEED_MAX_UPDATE_INTERVAL
        
        # If time since last post is less than 10 days, calculate the current interval
        if time_since_last_post > 0 and time_since_last_post < 864000
          # Calculate the current (current time and last 10 posts) update interval
          if current_count > 0 and current_sum > 0
            current_update_interval = (current_sum / current_count) / 240
          end

          # Calculate the historic (last 10 posts only) update interval
          if historic_count > 0 and historic_sum > 0
            historic_update_interval = (historic_sum / historic_count) / 240
          end

          update_interval = [current_update_interval,historic_update_interval].min
        end

      puts "[#{self.id}] TSLP: #{time_since_last_post/60} Historic:  #{historic_update_interval}   Current: #{current_update_interval}"

      end
    rescue
      #puts "here"
    end

    if (update_interval < FEED_MIN_UPDATE_INTERVAL)
      update_interval = FEED_MIN_UPDATE_INTERVAL
    elsif (update_interval > FEED_MAX_UPDATE_INTERVAL)
      update_interval = FEED_MAX_UPDATE_INTERVAL
    end

    # Multiply by a noise factor between 0.9 and 1.1
    update_interval *= (90.0+rand(21))/100.0

    next_update_time = (update_interval.minutes.since DateTime.now).to_s(:db)

    puts "[#{self.id}] Interval:  #{update_interval}   Next Update: #{next_update_time}"
    #puts "[#{self.id}] Sub Count:  #{self.users.count}"

    self.next_update_at = next_update_time
    next_update_at
  end

  def self.setup_feed(user, url, tags=nil)
    new_feed = Feed.find_by_url(url)

    if new_feed.nil? then
      new_feed = Feed.new
      new_feed.url = url
      new_feed.title = url
      new_feed.status = Feed::FEED_STATUS_NEW
      new_feed.users = []
      new_feed.tags = []
    new_feed.users.push(user)
    new_feed.save
    elsif user.feeds.include?(new_feed) then
    return
    else
      new_feed.users.push(user)
      new_feed.save
      Post.synchronize_posts_with_users(user.id, new_feed.id)
    end

    if not tags.nil? then
      tags.each do |tag|
        Tag.create(
        :user_id => user.id,
        :feed_id => new_feed.id,
        :name => tag.strip
        )
      end
    end

    new_feed.queue_feed_update
  end

  def queue_feed_update
    FeedUpdater.queue_feed_update(self)
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
