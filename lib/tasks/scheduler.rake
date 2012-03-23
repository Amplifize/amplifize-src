task :update_feeds => :environment do
    puts "Scheduling update feeds..."
    Feed.update_feeds
    rake "jobs:work"
end
