class FeedUpdater
  #@@sender = Redis.new

  def self.update_feed(feed_id)
    feed = Feed.find(feed_id)
    Post.get_new_posts(feed)
  end

  def self.queue_feed_update(feed)
    begin
      job = FeedUpdaterJob.new
      job.delay.run_update(feed.id)
      #@@sender.rpush("feed_upates", feed.id)
    rescue
      Post.get_new_posts(feed)
      Post.synchronize_posts_with_users(current_user.id, feed.id)
    end
  end
end