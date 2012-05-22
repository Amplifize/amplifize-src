class FeedUpdater
  #@@sender = Redis.new

  def self.update_feed(feed_id)
    feed = Feed.find(feed_id)
    Post.get_new_posts(feed)
  end

  def self.queue_feed_update(feed)
    begin
      puts "calling enqueue"
      #Delayed::Job.enqueue FeedUpdaterJob.new(feed.id)
      
      
      job = FeedUpdaterJob.new
      job.run_update(feed.id)
      
      
      #Delayed::Job.enqueue(FeedUpdaterJob.new)

      #@@sender.rpush("feed_upates", feed.id)
    rescue
      Post.get_new_posts(feed)
      Post.synchronize_posts_with_users(current_user.id, feed.id)
    end
  end
end