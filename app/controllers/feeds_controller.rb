class FeedsController < ApplicationController
  before_filter :require_user, :only => [:import, :create, :manage]
  def create
    setupFeed(Feed.check_feed_url(params[:feed][:url]), params[:feed][:tags].squish().split(","))

    respond_to do |format|
      format.js { render :json => '{"success": true}' }
    end
  end

  def manage
    @feeds = current_user.feeds.alphabetical
    @tags = current_user.tags
    @tag = Tag.new
    render :layout => false
  end

  def tagsByFeed
    tags = Tag.find_all_by_user_id_and_feed_id(current_user.id, params[:feed_id])
    
    respond_to do |format|
      format.js {render :json => {"feed_id" => params[:feed_id], "tags" => tags }}
    end
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
          setupFeed url, [tag]
        end
      end
    end

    respond_to do |format|
      format.html { redirect_to(reader_url) }
    end
  end

  private

  def setupFeed(url, tags=nil)
    new_feed = Feed.find_by_url(url)

    if new_feed.nil? then
      new_feed = Feed.new
      new_feed.url = url
      new_feed.title = url
      new_feed.status = Feed::FEED_STATUS_NEW
      new_feed.users = []
      new_feed.tags = []
      new_feed.users.push(current_user)
      new_feed.save
    elsif current_user.feeds.include?(new_feed) then
      return
    else
      new_feed.users.push(current_user)
      new_feed.save
      Post.synchronize_posts_with_users(current_user.id, new_feed.id)
    end

    if not tags.nil? then
      tags.each do |tag|
        Tag.create(
          :user_id => current_user.id,
          :feed_id => new_feed.id,
          :name => tag.strip
        )
      end
    end

    sendFeedForUpdate(new_feed)
  end

  def sendFeedForUpdate(feed)
    FeedUpdater.queue_feed_update(feed)
  end
end
