class FeedsController < ApplicationController
  before_filter :require_user

  def single_access_allowed?
    (action_name == "create")
  end

  def create
    feed_url = params[:feed][:url]
    
    valid_urls = FeedValidator.validate_feed_url(feed_url)
    
    if (valid_urls.length > 0) 
      # For now we'll just use the first URL found.  Eventually should
      # provide user with options to choose from
      url_to_use = valid_urls[0]
      Feed.setup_feed(current_user, url_to_use, params[:feed][:tags].squish().split(","))
    end

    respond_to do |format|
      format.js { render :json => '{"success": true}' }
    end
  end

  def show
    respond_to do |format|
      format.js { render :json => Feed.find_by_id(params[:id])}
    end
  end

  def manage
    @feeds = current_user.feeds.alphabetical
    @tags = current_user.tags
    @tag = Tag.new
    @feed = Feed.new

    @posts_unread_count = current_user.feeds_unread_count
    @shares_unread_count = current_user.shares_unread_count
    
    render :layout => 'reader_layout'
  end

  def clearAll
    if "all" != params[:filter]
      feeds = current_user.feeds.select("feeds.id").joins(:tags).where("tags.name = ?", params[:filter])
      posts_to_clear = PostUser.joins(:post).where("posts.feed_id IN (?) AND post_users.user_id = ? AND post_users.read_state = 1", feeds, current_user.id)
      posts_to_clear.update_all 'read_state=0'
    else 
      PostUser.update_all 'read_state = 0', ["user_id = ? AND post_users.read_state = 1", current_user.id]
    end

    respond_to do |format|
      format.js {render :json => '{"success": true}'}
    end
  end

  def tagsByFeed
    tags = Tag.find_all_by_user_id_and_feed_id(current_user.id, params[:feed_id])
    
    respond_to do |format|
      format.js {render :json => {"feed_id" => params[:feed_id], "tags" => tags }}
    end
  end
end
