class FeedStatus < ActiveRecord::Base
  
  def self.update_status(feed,status,message)
    last_status = FeedStatus.find_last_by_feed_id(feed.id)
    if last_status.nil? or last_status.status_code != status then
      create!(
        :feed_id => feed.id,
        :url => feed.url,
        :status_code => status,
        :update_time => Time.now.utc.to_s(:db),
        :message => message
      )
    end
    
    
    
  end
end
