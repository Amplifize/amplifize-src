class FollowsController < ApplicationController
  before_filter :require_user

  def add
    user_to_follow = User.find_by_id(params[:user_id])

    if not user_to_follow.nil? then
      if Follow.follow_user(current_user, user_to_follow)  then
        respond_to do |format|
          format.js { render :json => "{\"success\": true}" }
          format.html { redirect_to(:people, :notice =>"You have followed #{user_to_follow.visible_name}")}
        end
      else
        respond_to do |format|
          format.js { render :json => "{\"error\": \"Already following user\"}" }
          format.html { redirect_to(:people, :flash => {:notice =>"You're already following #{user_to_follow.visible_name}"})}
        end
      end
    else
      respond_to do |format|
        format.js { render :json => "{\"error\": \"Invalid user specified\"}" }
        format.html { redirect_to(:people, :flash => {:error =>"Error following user: Invalid user specified"})}
      end
    end
  end

  def unsubscribe
    #Find the follow
    follow = Follow.find_by_user_id_and_follows(current_user.id, params[:user_id])

    #Find all share_users
    shares = ShareUser.find_by_sql ["select * from share_users join shares on share_users.share_id = shares.id where shares.user_id = ? and share_users.user_id = ?", params[:user_id], current_user.id]
    shares.each do |share|
    #Destroy the share_users
      share.destroy
    end

    #Destroy the follow
    follow.destroy

    respond_to do |format|
      format.js {render :json => '{"success": true, "user_id": '+params[:user_id]+'}'}
    end
  end
end
