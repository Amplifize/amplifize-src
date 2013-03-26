class PostUsersController < ApplicationController
  before_filter :require_user, :only => [:set_read_state, :retrieve]

  def set_read_state
    post_id = params[:post_id]
    new_state = params[:state]

    post_user = PostUser.find_by_post_id_and_user_id(post_id, current_user.id)
    post_user.read_state = new_state
    post_user.save

    respond_to do |format|
      format.js {"{'success': true}"}
    end
  end

  def retrieve
    #build the @posts query based on user preferences
    if "titleView" == params[:content_layout]
      posts = current_user.post_users.select("post_users.*, feeds.title AS feed_title, posts.title AS post_title, posts.published_at AS published_at, posts.author AS author").joins(:post => :feed)
    else
      posts = current_user.post_users.select("post_users.post_id, post_users.read_state").joins(:post)
    end

    if "all" != params[:filter]
      feeds = current_user.feeds.select("feeds.id").joins(:tags).where("tags.name = ?", params[:filter])
      posts = posts.where("posts.feed_id IN (?)", feeds)
    end

    if params[:content_sort] == "unreadOnly" then
      posts = posts.unread
    end

    posts = posts.rolling_window

    if params[:content_order] == "oldestFirst" then
      posts = posts.oldest_to_newest
    else
      posts = posts.newest_to_oldest
    end

    posts = posts.limit(1000)

    respond_to do |format|
      format.js { render :json => posts }
      format.html { render :json => posts }
    end
  end
end