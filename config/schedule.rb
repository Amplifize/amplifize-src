every 10.minutes do
    rake "update_feeds"
    rake "jobs:work"
end