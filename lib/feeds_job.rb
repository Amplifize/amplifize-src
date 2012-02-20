class FeedsJob
  def perform
    puts "in the perform"
    feeds = Feed.all
    puts "got the feeds"
    feeds.each { |feed|
      puts "getting posts"
      Post.get_new_posts(feed.url, feed.id)
    }
    
    puts "Finished updating feeds"
  end
end