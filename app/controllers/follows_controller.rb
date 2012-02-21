class FollowsController < ApplicationController
  def add
    relationship = Follow.find_by_follower_and_followed(current_user.id, params[:user_id])
    
    if relationship.nil? then
      followee = User.find(params[:user_id])
      follow = Follow.new(:follower => current_user, :followed => followee)
      current_user.followers.push(follow)    

      respond_to do |format|
        format.js { render :json => followee }
      end
    else
      respond_to do |format|
        format.js { puts "{\"error\": \"Already following user\"}" }
      end
    end
  end
end
