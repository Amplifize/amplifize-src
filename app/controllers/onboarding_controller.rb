class OnboardingController < ApplicationController
  layout "onboarding"
  
  before_filter :require_user

  def import
    
  end

  def find_friends

  end

  def setup_profile
    @user = current_user
  end

  def the_rest
    @user = current_user
  end

end