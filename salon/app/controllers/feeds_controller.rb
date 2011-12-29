class FeedsController < ApplicationController
  def new
    @feed = Feed.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @feed }
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

    Post.synchronize_posts_with_users(current_user.id, @feed.id)

    respond_to do |format|
      format.js #{ render :json => @feed }
    end
  end
  
  # def import
    # require 'opml'
#   
    # opml_file = params[:feeds][:my_file].tempfile
    # opml_xml = Opml.new(opml_file)
#     
    # opml_xml.outlines.each do |feed|
      # url = feed.attributes['html_url']
      # if not url.nil? then
        # new_feed = Feed.find_by_url(url)
#   
        # if new_feed.nil? then
          # new_feed = Feed.new
          # new_feed.url = url
          # new_feed.users.push(current_user)
          # new_feed.save
        # else
          # new_feed.users.push(current_user)
        # end
      # else
        # puts "URL doesn't exist"
      # end
    # end
#     
    # respond_to do |format|
      # format.html { redirect_to(reader_url) }
    # end
  # end
#   
  # def refresh
    # feed = Feed.find(params[:feed_id])
    # feed.get_feed_posts
#     
    # @response = '{"success": true}'
#     
    # respond_to do |format|
      # format.js
    # end
  # end
end
