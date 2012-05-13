require 'date'
require 'Twitter'

Twitter.configure do |config|
  config.consumer_key = "hk0a3x3oU28KLXCJEEPig"
  config.consumer_secret = "0gJqF5tYrUMyh8HgcJFtQhbtTgsVNuOeRIBOVKlTxo"
  config.oauth_token = "119266837-NvoGkC1tBUP51EZr50e8uvkFpcnV4GSbelim7lYO"
  config.oauth_token_secret = "l7GU4A64BQL2ZWbGuytSy0jwyPZkZt92UuoSw3ela8"
end
class TwitterPost < ActiveRecord::Base
  belongs_to :feed
  #scope :desc, order("twitter_posts.tweet_id DESC")
  def self.get_latest_tweets
    puts "Running Twitter update..."

    last_tweet_id = get_last_tweet_id
    tweets = Twitter.mentions({:include_entities => true, :since_id => last_tweet_id})

    #puts tweets.to_yaml

    tweets.reverse_each { |tweet|
      puts "Processing Twitter ID #{tweet.id} for #{tweet.user.attrs["id"]}"
      url = tweet.expanded_urls.first
      if !url.nil? then
        create(tweet)
      end
    }

  #puts tweets.to_yaml
  end

  def self.create(tweet)
    twitter_screen_name = tweet.user.attrs["screen_name"]
    twitter_user_id = tweet.user.attrs["id"]
    full_screen_name = "@" "#{twitter_screen_name}"
    enclosed_url = tweet.expanded_urls.first

    # Check if we have a vaild feed for this Twitter account.  if not, initiliaze
    feed = Feed.find_or_initialize_by_url_and_feed_type(twitter_user_id, 2)
    if (!feed.persisted?) then
      puts "Creating new Twitter feed..."
    feed.title = full_screen_name
    feed.save
    end

    # update title if the screen name has changed
    if feed.title == full_screen_name then
    feed.title = full_screen_name
    feed.save
    end

    # add a new post for the twitter url
    post = Post.new
    post.title = "#{full_screen_name}: #{enclosed_url}"
    post.content = tweet.text
    post.url = enclosed_url
    post.uid = "twitter:#{tweet.id}"
    post.published_at = tweet.attrs["created_at"]
    post.feed_id = feed.id
    post.save

    # add the Twitter metadata post
    tp = TwitterPost.new
    tp.tweet_id = tweet.id
    tp.text = tweet.text
    tp.expanded_url = enclosed_url
    tp.twitter_user_id = twitter_user_id
    tp.feed_id = feed.id
    tp.post_id = post.id
    tp.save

  end

  def self.get_last_tweet_id
    last_entry = TwitterPost.find(:last, :order => "tweet_id")
    if !last_entry.nil? then
    last_entry.tweet_id.to_i
    else
    1
    end
  end
end
