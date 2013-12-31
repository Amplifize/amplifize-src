every 10.minutes do
    rake "update_feeds"
    #command "cd /home/amplifize.com/src && RAILS_ENV=production script/delayed_job -n 10 --queue=mail,feed_update start"
    command "cd /home/amplifize.com/src && RAILS_ENV=production script/delayed_job start -n 5 --exit-on-complete"
    rake ts:reindex
end