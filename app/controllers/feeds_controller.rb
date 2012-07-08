class FeedsController < ApplicationController
  before_filter :require_user, :only => [:import, :create, :manage]
  def create
    Feed.setup_feed(current_user, Feed.check_feed_url(params[:feed][:url]), params[:feed][:tags].squish().split(","))

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
        Feed.setup_feed(current_user, url)
      else
        tag = feed.attributes['title']
        feed.outlines.each do |feed_in_folder|
          url = feed_in_folder.attributes['xml_url']
          Feed.setup_feed(current_user, url, [tag])
        end
      end
    end

    respond_to do |format|
      format.html { redirect_to(reader_url) }
    end
  end

end
