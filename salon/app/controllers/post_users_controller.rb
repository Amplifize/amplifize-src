class PostUsersController < ApplicationController
  def set_read_state()
    post_id = params[:post_id]
    new_state = params[:state]
    
    post_user = PostUser.find_by_post_id_and_user_id(post_id, current_user.id)
    post_user.read_state = new_state
    post_user.save
    
    respond_to do |format|
      format.js {"{'success': true}"}
    end
  end
end