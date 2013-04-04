class PasswordResetsController < ApplicationController
  before_filter :require_no_user 
  before_filter :load_user_using_perishable_token, :only => [:edit, :update]
  
  def new
    @user_session = UserSession.new
  end
  
  def create
    @user = User.find_by_email(params[:email])  
    
    if @user  
      @user.deliver_password_reset_instructions!  
      redirect_to root_url
    else
      #TODO: Handle the error case here
      render :action => :new  
    end  
  end  
  
  def edit
    @user_session = UserSession.new
  end
  
  def update  
    @user.password = params[:user][:password]  
    @user.password_confirmation = params[:user][:password_confirmation]  
    if @user.save
      redirect_to homepage_url  
    else  
      render :action => :edit  
    end
  end  
  
  
  private  
  def load_user_using_perishable_token  
    @user = User.find_using_perishable_token(params[:id])  
    unless @user  
      redirect_to root_url  
    end  
  end
end
