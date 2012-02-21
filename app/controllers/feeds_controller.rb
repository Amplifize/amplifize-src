class FeedsController < ApplicationController
  def new
    @feed = Feed.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # POST /rss_feeds
  # POST /rss_feeds.xml
  def create
    @feed = Feed.find_by_url(params[:feed][:url])
    if @feed.nil? 
      @feed = Feed.new(params[:feed])
      @feed.save
      Post.get_new_posts(@feed.url, @feed.id)
    end

    @feed.users.push(current_user)

    @posts = Post.synchronize_posts_with_users(current_user.id, @feed.id)

    respond_to do |format|
      format.js { render :json => @posts.map(&:attributes) }
    end
  end

  def import
    require 'opml'

    opml_file = params[:feeds][:my_file].tempfile
    opml_xml = Opml.new(opml_file)

    posts = []
    opml_xml.outlines.each do |feed|
      url = feed.attributes['html_url']
      if not url.nil? then
        new_feed = Feed.find_by_url(url)

        if new_feed.nil? then
          new_feed = Feed.new
          new_feed.url = url
          new_feed.save
          Post.get_new_posts(url, new_feed.id)
        end

        new_feed.users.push(current_user)

        posts.insert(Post.synchronize_posts_with_users(current_user.id, @feed.id))
      end
    end

    #TODO: Figure out how to return the posts here
    respond_to do |format|
      format.html { redirect_to(reader_url) }
    end
  end

  def refresh
    feed = Feed.find(params[:feed_id])
    Post.get_new_posts(feed.url, feed.id)

    posts = Post.synchronize_posts_with_users(current_user.id, feed.id)

    respond_to do |format|
      format.js { render :json => posts.map(&:attributes) }
    end
  end

end
