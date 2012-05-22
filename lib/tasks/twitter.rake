task :update_twitter => :environment do
  require 'twitter_wrapper'
  
  puts "Updating Twitter feeds..."
  TwitterPost.get_latest_tweets
  puts "Done running Twitter update..."
end
