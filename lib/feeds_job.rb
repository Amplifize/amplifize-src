class FeedsJob
  def perform
    feeds = Feed.all
    feeds.each { |feed|
      FeedUpdater.queue_feed_update(feed)
    }
  end
end