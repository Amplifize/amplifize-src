class UsersController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:reader, :update, :search, :profile]

  def new
    @user = User.new
    @user_session = UserSession.new
  end

  def create
    @user = User.new(params[:user])
    @invite_id = params[:invite_id]

    respond_to do |format|
      if @user.save
        Invite.handle_new_user(@invite_id, @user)
        Mailer.delay.new_user_email(@user)
        
        format.html { redirect_to(:reader, :notice => 'Welcome to amplifize') }
        format.xml  { render :xml => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end  
  end


  def update
    @user = current_user
   
    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.js {render :json => {:status => 0}}
      else
        format.js { render :json => {:status => :unprocessable_entity, :errors => @user.errors } }
      end
    end
  end

  def profile
    @user = current_user
    @posts_unread_count = current_user.feeds_unread_count
    @shares_unread_count = current_user.shares_unread_count

    render :layout => 'reader_layout'
  end

  def unsubscribe
    @feed = Feed.find(params[:feed_id])
    
    Tag.delete_all("user_id=#{current_user.id} AND feed_id=#{params[:feed_id]}")

    @feed.posts.each do |post|
      current_user.posts.delete(post)
    end
    
    current_user.feeds.delete(@feed)
    
    respond_to do |format|
      format.html {redirect_to(reader_url)}
      format.js
    end
  end

  def reader
    if params[:read_state] then
      session[:read_state] = params[:read_state]
    end
    
    if params[:content_order] then
      session[:content_order] = params[:content_order]
    end
    
    case params[:view]
    when "shares"
      #build the @shares query based on user preferences
      @shares = current_user.shares

      #TODO Re-write to use the follower id instead
      #if params[:feed_id]
      #  @posts = @posts.where("feed_id = ?", params[:feed_id])
      #end

      if session[:read_state] == "unread" then
        @shares = @shares.unread
      end

      if session[:read_order] == "oldToNew" then
        @shares = @shares.oldest_to_newest
      else
        @shares = @shares.newest_to_oldest
      end

      @shares = @shares.map(&:id).to_json

      @comment = Comment.new
      @posts_unread_count = current_user.feeds_unread_count
      @followed = User.find_by_sql ['select users.* from users where id in (select follows from follows where user_id = ?)', current_user.id]
      render_view = 'users/reader/shares.html.erb'
    when "people"
      @subscribed_to = User.find_by_sql ['select users.* from users join follows on users.id = follows.follows where user_id = ?', current_user.id]
      @followed_by = User.find_by_sql ['select distinct users.* from users join follows on users.id = follows.user_id where follows.follows = ?', current_user.id]
      @posts_unread_count = current_user.feeds_unread_count
      @shares_unread_count = current_user.shares_unread_count
      render_view = 'users/reader/people.html.erb'
    else
      @feed = Feed.new
      @my_feeds = current_user.feeds.alphabetical;
      
      #build the @posts query based on user preferences
      @posts = current_user.posts
      
      if params[:feed_id]
        @posts = @posts.where("feed_id = ?", params[:feed_id])
      end

      if session[:read_state] == "unread" then
        @posts = @posts.unread
      end

      @posts = @posts.rolling_window

      if session[:read_order] == "oldToNew" then
        @posts = @posts.oldest_to_newest
      else
        @posts = @posts.newest_to_oldest
      end

      @posts = @posts.map(&:id).to_json

      @shares_unread_count = current_user.shares_unread_count
      render_view = 'users/reader/feeds.html.erb'
    end
    
    render :file => render_view, :layout => 'reader_layout'
  end
  
  def search
    user = User.find_by_email(params[:email])
    
    respond_to do |format|
      format.js { render :json => user }
    end
  end
end
