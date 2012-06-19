class FollowsController < ApplicationController
  def add
    relationship = Follow.find_by_user_id_and_follows(current_user.id, params[:user_id])
    
    if relationship.nil? then
      follow = Follow.create(:user_id => current_user.id, :follows => params[:user_id]) 

      respond_to do |format|
        format.js { render :json => "{\"success\": true}" }
      end
    else
      respond_to do |format|
        format.js { render :json => "{\"error\": \"Already following user\"}" }
      end
    end
  end  
end
