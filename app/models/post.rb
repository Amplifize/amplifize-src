require 'date'

class Post < ActiveRecord::Base
  attr_accessible :title, :author, :content, :url, :published_at, :uid, :feed_id
  
  belongs_to :feed

  has_many :post_users
  has_many :users, :through => :post_users

  after_create :attach_to_users
  
  scope :last_ten, lambda {
    select(:published_at).order("posts.published_at DESC").limit(10)
  }
  
  scope :filter_by_feed, lambda { |feed_id|
    where(:feed_id => feed_id)
  }
  
  scope :filter_by_tag, lambda { |tag_name,user_id|
    tags = Tag.arel_table
    where(:feed_id => tags.project(:feed_id).where(tags[:name].eq(tag_name)).where(tags[:user_id].eq(user_id)))
  }

  def self.get_new_posts(feed)
    if feed.feed_type != Feed::FEED_TYPE_RSS
      return
    end
    
    feed_status_code = Feed::FEED_STATUS_OK
    feed_status_message = nil
    
    options = {}
    options[:max_redirects] = 5
    options[:timeout] = 15
    options[:on_success] = lambda {|url, feed_data| feed_status_code = Feed::FEED_STATUS_OK }
    options[:on_failure] = lambda {|url, response_code, response_header, response_body, exception| 
      if not exception.nil? 
        feed_status_message = exception.message
      end
      feed_status_code = Feed::FEED_STATUS_ERROR 
      puts "ERROR [#{response_code}]:  #{feed_status_message}"
    }
    
    if not feed.last_update_date.nil? then
      options[:if_modified_since] = feed.last_update_date
    end

    rss_feed = Feedzirra::Feed.fetch_and_parse(feed.url, options)

    if not rss_feed.nil? and not rss_feed.is_a? Fixnum then
      add_entries(rss_feed.entries, feed.id)
      feed.title = rss_feed.title
    end


    feed.status = feed_status_code
    feed.last_update_date = Time.now.utc.to_s(:db)
    # Calculate next update time for feeds
    feed.calculate_next_update
    feed.save
    
    # Check if feed status list needs to be updated to reflect current status
    FeedStatus.update_status(feed,feed_status_code,feed_status_message)
  end

  def self.synchronize_posts_with_users(user_id, feed_id)
    posts = Post.find_all_by_feed_id(feed_id, :order => 'created_at DESC', :limit => 10)
    
    begin
      posts.each do |post|
        PostUser.create!(
          :post_id      => post.id,
          :user_id      => user_id,
          :read_state   => 1
        )
      end
    rescue ActiveRecord::StatementInvalid => e
      raise e unless /Mysql2::Error: Duplicate entry/.match(e)
    end

    return posts
  end

  def attach_to_users
    if not self.feed_id.nil?
      feed = Feed.find_by_id(self.feed_id)
      feed.users.each do |user|
        begin
          PostUser.create!(
            :post_id      => self.id,
            :user_id      => user.id,
            :read_state   => 1
          )
        rescue ActiveRecord::StatementInvalid => e
          raise e unless /Mysql2::Error: Duplicate entry/.match(e)
        end
      end
    end
  end

  def self.add_entries(entries, feed_id)
    entries.each do |entry|
      title = ""
      content = ""
      if not entry.content.nil? 
        content = entry.content.html_safe
      elsif not entry.summary.nil?
        content = entry.summary.html_safe
      end
      
      conditions = {:uid => entry.id, :feed_id => feed_id}
      begin
        if not exists?(conditions)
          create!(
            :title        => entry.title.nil? ? entry.url : entry.title.html_safe,
            :author       => entry.author,
            :content      => content,
            :url          => entry.url,
            :published_at => entry.published.nil? ? Time.now.utc.to_s(:db) : entry.published,
            :uid          => entry.id,
            :feed_id      => feed_id
          )
          puts "Added #{feed_id}/#{entry.id}"
        else 
          #puts "Not adding #{feed_id}/#{entry.id}"
        end
      rescue Exception => e
        puts "Error adding post #{e}"
        next
      end
    end
  end
end
