desc "This task is called by the Heroku scheduler add-on"
task :update_feeds => :environment do
    puts "Updating feeds..."
    Feed.update_feeds
    puts "done."
end
