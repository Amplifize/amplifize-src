class OnboardingController < ApplicationController
  layout "onboarding"
  
  before_filter :require_user

  def import
    @tags = Tag.all.uniq{|tag| tag.name}
    @feed = Feed.new
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