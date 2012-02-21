desc "This task is called by the Heroku scheduler add-on"
task :update_feeds => :environment do
    puts "Scheduling update feeds..."
    Feed.update_feeds
end
