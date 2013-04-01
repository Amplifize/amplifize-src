class InviteController < ApplicationController
  before_filter :require_user, :only => :create
  
  def create
    Invite.create(current_user, [params[:email]], params[:message])

    respond_to do |format|
      format.js { render :json => "{\"success\": true}" }
    end

  end

  def respond
    @user = User.new
    @user_session = UserSession.new

    @invite = Invite.find_by_uid(params[:invite_id])
    if not @invite.nil? 
      @invite_id = @invite.uid
      @user.email = @invite.email
    end
  end

end