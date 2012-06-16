class PostsController < ApplicationController
  
  def by_feed
    feed_id = params[:feed_id]
    posts = current_user.posts.filter_by_feed(feed_id).unread.rolling_window.desc.map(&:id)
    
    respond_to do |format|
      format.js {render :json => posts.to_json}
    end
  end
  
  def by_tag
    tag_id = params[:tag_id]
    posts = current_user.posts.filter_by_tag(tag_id,current_user.id).unread.rolling_window.desc.map(&:id)
    
    respond_to do |format|
      format.js {render :json => posts.to_json}
    end
  end
  
  def show
    post = Post.find_by_id(params[:id])
    
    respond_to do |format|
      format.js {render :json => post.to_json(
        :include => {
          :feed => {}
        }
      )}
    end
  end
end