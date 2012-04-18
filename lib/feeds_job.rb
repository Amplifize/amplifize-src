class FeedsJob
  def perform
    feeds = Feed.all
    feeds.each { |feed|
      puts "Get new posts for " + feed.url
      Post.get_new_posts(feed.url, feed.id, feed.last_update_date)

      feed.last_update_date = Time.now.utc.to_s(:db)
      feed.save
    }

    puts "Finished updating feeds"
  end
end