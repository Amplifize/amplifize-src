require 'date'

class Post < ActiveRecord::Base
  belongs_to :feed

  has_many :post_users
  has_many :users, :through => :post_users

  after_create :attach_to_users

  scope :desc, order("posts.published_at ASC")
  
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
  
  scope :unread, lambda {
    where("post_users.read_state = 1")
  }
  
  scope :rolling_window, lambda {
    where("posts.published_at > '" + (DateTime.now << 2).to_s(:db) + "'")
  }

  def self.get_new_posts(feed)
    if feed.feed_type != Feed::FEED_TYPE_RSS
      return
    end
    
    feed_status_code = Feed::FEED_STATUS_OK

    options = {}
    options[:on_success] = lambda {|url, feed_data| feed_status_code = Feed::FEED_STATUS_OK }
    options[:on_failure] = lambda {|url, response_code, response_header, response_body| feed_status_code = Feed::FEED_STATUS_ERROR }
    
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
    FeedStatus.update_status(feed,feed_status_code)
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

  def self.add_entries(entries, feed_id)
    entries.each do |entry|
      begin
        unless exists? :uid => entry.id
          create!(
            :title        => entry.title.html_safe,
            :author       => entry.author,
            :content      => entry.content.nil? ? entry.summary.html_safe : entry.content.html_safe,
            :url          => entry.url,
            :published_at => entry.published.nil? ? Time.now.utc.to_s(:db) : entry.published,
            :uid          => entry.id,
            :feed_id      => feed_id
          )
        end
      rescue
        next
      end
    end
  end
end
