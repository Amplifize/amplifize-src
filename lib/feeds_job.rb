class FeedsJob
  def perform
    feeds = Feed.all
    feeds.each { |feed|
      Post.get_new_posts(feed)
    }

    puts "Finished updating feeds"
  end
end