class UserSessionsController < ApplicationController
  
  def oauth2_request
    require_dependency 'oauth2_handler'
    service = params[:service]
    
    if service.nil?
      raise "No service specified"
    end
    
    oauth = OAuth2_Handler.new(session)
    url = oauth.get_auth_url(service.to_sym)
    
    redirect_to(url)
  end
  
  
  def oauth2_response
    require_dependency 'oauth2_handler'
    nonce = params[:state]
    access_code = params[:code]
    oauth = OAuth2_Handler.new(session)
    oauth.authorize_token(nonce,access_code)
  end
  
  # GET /user_sessions/new
  # GET /user_sessions/new.xml
  def new
    @user_session = UserSession.new
  
    if params[:u] then
      @user_session.email = params[:u]
    end

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user_session }
    end
  end

  # POST /user_sessions
  # POST /user_sessions.xml
  def create
    @user_session = UserSession.new(params[:user_session])

    respond_to do |format|
      if @user_session.save
        format.html { redirect_to(:reader, :notice => 'Login Successful') }
        format.xml  { render :xml => @user_session, :status => :created, :location => @user_session }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user_session.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /user_sessions/1
  # DELETE /user_sessions/1.xml
  def destroy
    @user_session = UserSession.find    
    @user_session.destroy

    reset_session

    respond_to do |format|
      format.html { redirect_to(:root, :notice => 'Goodbye!') }
      format.xml  { head :ok }
    end
  end
end

