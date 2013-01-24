class ShareUsersController < ApplicationController
  before_filter :require_user, :only => [:set_read_state, :retrieve]
  
  def set_read_state
    share_id = params[:share_id]
    new_state = params[:state]
    
    share_user = ShareUser.find_by_share_id_and_user_id(share_id, current_user.id)
    share_user.read_state = new_state
    share_user.save
    
    respond_to do |format|
      format.js {"{'success': true}"}
    end
  end
  
  def retrieve
    #build the @shares query based on user preferences
    if "titleView" == params[:content_layout]
      shares = current_user.share_users.select("share_users.*, posts.title AS post_title, users.display_name AS display_name, users.email AS email").joins(:user, :share => [:post])
    else
      shares = current_user.share_users.select("share_users.share_id, share_users.read_state").joins(:share)
    end

    #TODO: Fix this
    #if params[:follower_id]
    #  shares = @shares.joins(:share).where("shares.user_id = ?", params[:follower_id])
    #end

    if params[:content_sort] == "unreadOnly" then
      shares = shares.unread
    end

    if params[:content_order] == "oldestFirst" then
      shares = shares.oldest_to_newest
    else
      shares = shares.newest_to_oldest
    end

    respond_to do |format|
      format.js { render :json => shares }
      format.html { render :json => shares }
    end

  end
end
    
      #feeds.title AS feed_title, posts.title AS post_title, posts.published_at AS published_at, posts.author AS author").joins(:post => :feed)
