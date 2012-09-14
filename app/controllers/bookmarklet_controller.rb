require 'readability'
require 'open-uri'

class BookmarkletController < ApplicationController
  
  def single_access_allowed?
    true
  end
  

  
  def share
    
    puts request.to_yaml
    
    url = params[:url]
    comment = params[:comment]
    title = params[:title]
    content = params[:content]
    
    extracted_text = Readability::Document.new(content, :debug => true)
    
    
    #puts extracted_text.content
    Share.add_ext(comment, url, title, extracted_text.content, current_user.id)
    
    response.headers['Access-Control-Allow-Origin'] = '*';
    respond_to do |format|
      format.json { render :json => {:status => "0"} }
    end
  end
  
  def share_prompt
    puts current_user.to_yaml
    
    url = params[:url]
    #html = open(url).read
    #puts html
    #text = Readability::Document.new(html, :debug => true)
    #puts text
    #Share.add_ext('summary', url, text.title, text.content, current_user.id)
    
    render_api
  end
  
  def sub
    
    
  end
  
  private
  
  def render_api
    
    #puts params[:api_version]
    #puts params[:access_token]
    
    render :file => 'bookmarklet/api', :layout => nil, :content_type => 'application/javascript'
  end
end