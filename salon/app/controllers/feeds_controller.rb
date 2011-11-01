class FeedsController < ApplicationController
  def show
    @feed = Feed.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @feed }
    end
  end

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
    end

    respond_to do |format|
      if @feed.save
        current_user.feeds.push(@feed)
        
        format.html { redirect_to(:reader, :notice => 'Feed was successfully added.') }
        format.xml  { render :xml => @feed, :status => :created, :location => @feed }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @feed.errors, :status => :unprocessable_entity }
      end
    end
  end
end
