class FeedUpdater
  def self.queue_feed_update(feed)
    #begin
      # Using the "delay" syntax queues to delayed_job
      FeedUpdater.delay.run_update(feed.id)
      #@@sender.rpush("feed_upates", feed.id)
    #rescue
    #  Post.get_new_posts(feed)
    #  #Post.synchronize_posts_with_users(current_user.id, feed.id)
    #end
  end
  
  
  def self.run_update(feed_id)
    thread_num = 0
    puts ">> Updating feed #{feed_id}"
    t = Timer.new
    begin
      FeedUpdater.update_feed(feed_id)
    rescue Exception => e
      puts "!! Error with feed #{feed_id}: #{e} : #{t.elapsed}ms"
      #next
    end

    puts "<< Done with feed #{feed_id} : #{t.elapsed}ms"
  end
  
  def self.update_feed(feed_id)
    feed = Feed.find(feed_id)
    Post.get_new_posts(feed)
  end

end