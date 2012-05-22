class FeedUpdaterJob
  def perform
    run_update(feed_id)
  end
  
  def run_update(feed_id)
      thread_num = 0
      puts ">> [#{thread_num}] Updating feed #{feed_id}"
      t = Timer.new
      begin 
        FeedUpdater.update_feed(feed_id)
      rescue Exception => e
        puts "!! [#{thread_num}] Error with feed #{feed_id}: #{e} : #{t.elapsed}ms" 
        next
      end
      
      puts "<< [#{thread_num}] Done with feed #{feed_id} : #{t.elapsed}ms"
  end
  handle_asynchronously :run_update
  
end
