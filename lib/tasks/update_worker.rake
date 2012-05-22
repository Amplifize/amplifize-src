task :update_worker => :environment do
  require 'redis'
  require 'json'

max_workers = 10
threads = []

r = Redis.new

# Generate worker threads for the feed listener
for i in 0..max_workers
  threads << Thread.new(i) do |thread_num|
    puts "[#{thread_num}] Starting new worker thread ..."

    while true do
    
      # Wait for new entry from the Redis queue
      data = r.blpop("feed_upates", 0)
      feed_id = data[1]
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
  end
end


# Join the threads and wait for completion
threads.each do |aThread|  
  aThread.join
end

end
