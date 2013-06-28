every 10.minutes do
    rake "update_feeds"
    command "RAILS_ENV=production script/delayed_job -n 10 --queue=mail,feed_update start"
end