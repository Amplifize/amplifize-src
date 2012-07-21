class FollowsController < ApplicationController
  def add
    relationship = Follow.find_by_user_id_and_follows(current_user.id, params[:user_id])
    
    if relationship.nil? then
      follow = Follow.create(:user_id => current_user.id, :follows => params[:user_id]) 
      Mailer.delay.new_follower_email(User.find_by_id(params[:user_id]), current_user)
      
      respond_to do |format|
        format.js { render :json => "{\"success\": true}" }
      end
    else
      respond_to do |format|
        format.js { render :json => "{\"error\": \"Already following user\"}" }
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
