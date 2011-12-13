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
    saveFeed = false
    @feed = Feed.find_by_url(params[:feed][:url])
    if @feed.nil? 
      @feed = Feed.new(params[:feed])
      saveFeed = true
    end

    @feed.users.push(current_user)

    respond_to do |format|
      if saveFeed then
        @feed.save
      end

      format.js #{ render :json => @feed }
    end
  end
  
  def import
    
  end
  
  def refresh
    
  end
end
