require 'readability'
require 'open-uri'

# Class for handling actions from browser bookmarklets
# Calls to this controller will likely be XDR
# or JSONP and ar eintended for use with a single access token
class BookmarkletController < ApplicationController
  before_filter :require_user
  
  def single_access_allowed?
    true
  end
  
  # Shares a URL with a comment and extracted text content
  # If fetch is 1, then will retrieve text content from the
  # given URL on a delayed task
  def share
    
    fetch = params[:fetch]
    url = params[:url]
    comment = params[:comment]
    title = params[:title]
    content = params[:content]
    
    if (fetch == "1")
      BookmarkletController.delay.do_fetch_and_share(url,comment,title,current_user)
    else
      BookmarkletController.do_share(url,comment,title,content,current_user)
    end
    
    response.headers['Access-Control-Allow-Origin'] = '*';
    respond_to do |format|
      format.json { render :json => {:status => "0"} }
    end
  end
  
  # JSONP operation to get Share bookmarklet JS API 
  # for a given single access token
  def share_prompt
    url = params[:url]
    render_api
  end
  
  def sub
  end
  
  # Executes text extraction for a given string and creates
  # a new share for the user based on the text
  def self.do_share(url,comment,title,content,user)
    extracted_text = Readability::Document.new(content, :debug => true)
    Share.add_ext(comment, url, title, extracted_text.content, user.id)
  end
  
  # Fetches the content for the URL and passes
  # to do_share method for applying the share
  def self.do_fetch_and_share(url,comment,title,user)
    puts "Running Fetch and Share for URL #{url}"
    begin  
      content = open(url).read
    rescue
      content = ''
    end
    do_share(url,comment,title,content,user)
  end

  private
  
  # Retrieve and render the JS API for the Amplifize Bookmarklets
  # for the given user
  def render_api
    #puts params[:api_version]
    render :file => 'bookmarklet/api', :layout => nil, :content_type => 'application/javascript'
  end
end