class FollowsController < ApplicationController
  def add
    relationship = Follow.find_by_follower_and_followed(current_user.id, params[:user_id])
    
    if relationship.nil? then
      follow = Follow.create(:follower => current_user.id, :followed => params[:user_id]) 

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
