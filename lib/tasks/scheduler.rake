task :update_feeds => :environment do
    puts "Scheduling update feeds..."
    Feed.update_feeds
end
