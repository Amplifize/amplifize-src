class HomeController < ApplicationController
  before_filter :require_no_user, :only => :index
  
  def index
    @user_session = UserSession.new
  end
  
  def about
    @user_session = UserSession.new
  end
  
  def contact
    @user_session = UserSession.new
  end
  
  def faq
    @user_session = UserSession.new
  end
  
  def team
    @user_session = UserSession.new
    render :file => 'home/about/team'
  end
  
  def terms
    @user_session = UserSession.new
  end
  
  def why_amplifize
    @user_session = UserSession.new
    render :file => 'home/about/why'
  end
  
  def google_verification
    render :layout => false
  end
  
  def verifyforzoho
    render :layout => false
  end
end