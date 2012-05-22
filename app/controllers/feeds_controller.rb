class FeedsController < ApplicationController
  before_filter :require_user, :only => [:import, :refresh]
  def new
    @feed = Feed.new

    respond_to do |format|
      format.html {render :layout => false}# new.html.erb
    end
  end

  # POST /rss_feeds
  # POST /rss_feeds.xml
  def create
    new_url = Feed.check_feed_url(params[:feed][:url])

    feed = Feed.find_by_url(new_url)
    if feed.nil?
      params[:feed][:url] = new_url
      feed = Feed.new(params[:feed])
      feed.title = new_url
      feed.users.push(current_user)
      feed.status = 2
      feed.save

      sendFeedForUpdate(feed)

    #Post.get_new_posts(feed)
    else
      feed.users.push(current_user)
      Post.synchronize_posts_with_users(current_user.id, feed.id)
    end

    respond_to do |format|
      format.js { '{"success": true}' }
    end
  end

  def manage
  
    Feed.update_feeds
  
    @feeds = current_user.feeds
    render :layout => false
  end

  def import
    require 'opml'

    opml_file = params[:feeds][:my_file].tempfile
    opml_xml = Opml.new(opml_file)

    opml_xml.outlines.each do |feed|
      url = feed.attributes['xml_url']

      if not url.nil? then
        setupFeed url
      else
        tag = feed.attributes['title']
        feed.outlines.each do |feed_in_folder|
          url = feed_in_folder.attributes['xml_url']
          setupFeed url, tag
        end
      end
    end

    respond_to do |format|
      format.html { redirect_to(reader_url) }
    end
  end

  def refresh
    feed = Feed.find(params[:feed_id])
    Post.get_new_posts(feed)

    posts = Post.synchronize_posts_with_users(current_user.id, feed.id)

    respond_to do |format|
      format.js { render :json => posts.map(&:attributes) }
    end
  end

  private

  def setupFeed(url, tag=nil)
    new_feed = Feed.find_by_url(url)

    if new_feed.nil? then
      new_feed = Feed.new
      new_feed.url = url
      new_feed.title = url
      new_feed.status = 2
      new_feed.users = []
      new_feed.tags = []
      new_feed.users.push(current_user)
      new_feed.save

    #Post.get_new_posts(url, new_feed.id)
    elsif current_user.feeds.include?(new_feed) then
    return
    else
      new_feed.users.push(current_user)
      new_feed.save
      Post.synchronize_posts_with_users(current_user.id, new_feed.id)
    end

    if not tag.nil? then
      Tag.create(
      :user_id => current_user.id,
      :feed_id => new_feed.id,
      :name => tag
    )
    end

    sendFeedForUpdate(new_feed)

  end

  def sendFeedForUpdate(feed)
    FeedUpdater.queue_feed_update(feed)
  end

end
