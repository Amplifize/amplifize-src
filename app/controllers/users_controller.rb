class UsersController < ApplicationController
  autocomplete :tag, :name, :full => true

  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:hompage, :content, :conversations, :people, :update, :search, :profile]

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

        UserSession.create(@user)
        format.html { redirect_to(:homepage, :notice => 'Welcome to amplifize') }
      else
        format.html { render :action => "new" }
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
    set_unread_counts

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
      format.html {redirect_to(:feeds_manage)}
      format.js
    end
  end

  def homepage
    set_unread_counts
    
    render :file => 'users/reader/home', :layout => 'reader_layout'
  end

  def content
    set_unread_counts
    @feed = Feed.new

    render :file => 'users/reader/feeds.html.erb', :layout => 'reader_layout'
  end

  def people  
    set_unread_counts

    @subscribed_to = User.find_by_sql ['select users.* from users join follows on users.id = follows.follows where user_id = ?', current_user.id]
    @followed_by = User.find_by_sql ['select distinct users.* from users join follows on users.id = follows.user_id where follows.follows = ?', current_user.id]

    render :file => 'users/reader/people', :layout => 'reader_layout'
  end

  def conversations
    set_unread_counts

    @all_follows = current_user.follows.map(&:follows)
    @all_follows << current_user.id
    @all_follows = @all_follows.to_json

    @comment = Comment.new

    render :file => 'users/reader/shares', :layout => 'reader_layout'
  end
  
  def search
    user = User.find_by_email(params[:email])
    
    respond_to do |format|
      format.js { render :json => user }
    end
  end

  def get_autocomplete_items(parameters)
    super(parameters).group("tags.name")
  end

  private
  
  def set_unread_counts
    @posts_unread_count = current_user.feeds_unread_count
    @shares_unread_count = current_user.shares_unread_count
  end
end
