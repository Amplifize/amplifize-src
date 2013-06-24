class FeedUpdater
  def self.queue_feed_update(feed)
      FeedUpdater.delay(:queue => "feed_update").run_update(feed.id)
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