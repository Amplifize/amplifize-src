class FeedsJob
  def perform
    # Get feeds to update from interval scope
    feeds = Feed.to_update
    feeds.each { |feed|
      FeedUpdater.queue_feed_update(feed)
    }
  end
end