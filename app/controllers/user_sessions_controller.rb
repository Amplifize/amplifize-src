class UserSessionsController < ApplicationController  
  # GET /user_sessions/new
  # GET /user_sessions/new.xml
  def new
    @user_session = UserSession.new
  
    if params[:u] then
      @user_session.email = params[:u]
    end

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # POST /user_sessions
  # POST /user_sessions.xml
  def create
    @user_session = UserSession.new(params[:user_session])

    respond_to do |format|
      if @user_session.save        
        format.html { redirect_back_or_default(:homepage, 'Login Successful') }
      else
        format.html { render :action => "new" }
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
    end
  end
  
  
  def redirect_back_or_default(default, notice)
    redirect_to(session[:return_to] || default, :notice => notice)
    session[:return_to] = nil
  end  
end

