module FeedUpdater
  class <<self
    def update_tweets
      puts "Updating..."
      puts Twitter.methods.to_yaml
    end
  end
end