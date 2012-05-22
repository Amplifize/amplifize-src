class UsersController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:reader, :update, :search]

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.xml
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        format.html { redirect_to(:reader, :notice => 'Welcome to amplifize') }
        format.xml  { render :xml => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end  
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to(@user, :notice => 'Update was successful.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(root_url) }
      format.xml  { head :ok }
    end
  end

  def unsubscribe
    @feed = Feed.find(params[:feed_id])
    
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
    render_view = 'users/reader/feeds.html.erb'
    case params[:view]
    when "shares"
      @shares = current_user.shares.desc.map(&:id).to_json
      @comment = Comment.new
      render_view = 'users/reader/shares.html.erb'
    when "people"
      @my_follows = Follow.find_all_by_follower(current_user.id)
      render_view = 'users/reader/people.html.erb'
    when "account"
      @user = User.new
      render_view = 'users/reader/account.html.erb'
    else
      @feed = Feed.new
      @my_feeds = current_user.feeds;
      @posts = current_user.posts.unread.rolling_window.desc.map(&:id).to_json
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
