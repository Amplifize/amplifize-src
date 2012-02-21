class FeedsJob
  def perform
    feeds = Feed.all
    feeds.each { |feed|
      Post.get_new_posts(feed.url, feed.id)
    }

    puts "Finished updating feeds"
  end
end