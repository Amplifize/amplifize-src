class HomeController < ApplicationController
  before_filter :require_no_user, :only => :index
  
  def team
    render :file => 'home/about/team'    
  end
  
  def why_amplifize
    render :file => 'home/about/why'
  end
  
  def google_verification
    render :layout => false
  end
end