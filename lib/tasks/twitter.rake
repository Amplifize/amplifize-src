task :update_twitter => :environment do
  #require TwitterWrapper  
  
  #TwitterWrapper.update_tweets
  puts "Updating Twitter feeds..."
  TwitterPost.get_latest_tweets
  puts "Done running Twitter update..."
  # last_id = 200797329513648127;
  # #tweets = Twitter.mentions({:include_entities => true, :since_id => last_id}).to_yaml; #user("mattadav").methods
  # #puts tweets.to_yaml;
# 
  # username = "mattadav"
# 
  # feed = Feed.find_or_initialize_by_url_and_feed_type(username, 2)
  # if (!feed.persisted?) then
    # puts "Creating new Twitter feed..."
    # feed = Feed.new
    # feed.url = username
    # feed.feed_type = 2
    # feed.title = "@" "#{username}"
    # feed.users = []
    # feed.tags = []
    # puts feed.save
  # end
#   
#   
# 
  # puts feed.url
  # puts feed.id
end
