class HomeController < ApplicationController
  before_filter :require_no_user, :only => :index

  def index
    @user = User.new
  end
end