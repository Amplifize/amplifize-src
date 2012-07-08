class ImportController < ApplicationController

  def import
    require_dependency 'importer'
    
    feeds = params[:feeds]
    tags = params[:tags]
    
    if !feeds.nil? 
      Importer::do_import(current_user,feeds,tags)
      @success = true
    end 
    
    render
  end
  
  def google
    require_dependency 'oauth2_handler'
    require_dependency 'importer'
    
    begin
      oauth = OAuth2_Handler.new(session)
      
      @authorized = oauth.is_authorized?(:google)
      if @authorized
        subscriptions = Importer::Google.load_feeds(current_user,oauth) 
        @subscribed = subscriptions[:subscribed]
        @unsubscribed = subscriptions[:unsubscribed]
      else
        @authorize_url = url_for oauth2_request_path(:google)
      end
    rescue => e
      @error = e
      @error_message = e.message
      respond_to do |format|
        format.html { render :template => 'general/error' }
      end
    end
  end

end