class Feed < ActiveRecord::Base
  has_many :posts
  
  has_and_belongs_to_many :users
  
  validates_uniqueness_of :url

  def self.update_feeds
    feeds = Feed.all

    feeds.each { |feed|

      posts = Feedzirra::Feed.fetch_and_parse(feed.url)
    
      posts.entries.each { |post|
        new_post = Post.new
        new_post.feed_id = feed.id
        new_post.title = post.title
        new_post.url = post.url
        new_post.created_dt = post.published
        new_post.content = post.content
        
        new_post.save
        
        feed.users.each { |user|
          new_post_user = PostsUsers.new
          new_post_user.post_id = new_post.id
          new_post_user.user_id = user.id
          new_post_user.read_state = 1
          
          new_post_user.save
        }
        
      }
    }
  end
end
