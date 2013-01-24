class Share < ActiveRecord::Base
  attr_accessible :post_id, :user_id, :summary

  has_many :comments
  
  belongs_to :user
  belongs_to :post
  
  def self.add(summary, post_id, user_id)
    #Step 1 generate the share
    share = Share.create(
      :post_id      => post_id,
      :user_id      => user_id,
      :summary      => summary
    )

    #Step 2 create the share_user entry for posting user in read state
    ShareUser.create(
      :share_id     => share.id,
      :user_id      => user_id,
      :read_state   => 0
    )

    followers = Follow.find_all_by_follows(user_id)

    if not followers.nil? then
      #Step 3 let all followers know in unread state
      followers.each do |follower|
        ShareUser.create(
          :share_id      => share.id,
          :user_id      => follower.user_id,
          :read_state   => 1
        )
      end
    end
    
    share
  end
  
  def self.add_ext(summary, url, post_title, post_text, user_id)
    # create post
    post = Post.create(
            :title        => post_title.html_safe,
            :content      => post_text.html_safe,
            :url          => url,
            :published_at => Time.now.utc.to_s(:db)
          )
    post.save
    
    add(summary, post.id, user_id)
  end

end
