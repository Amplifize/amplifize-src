class ShareUsersController < ApplicationController
  def set_read_state
    share_id = params[:share_id]
    new_state = params[:state]
    
    share_user = ShareUser.find_by_share_id_and_user_id(share_id, current_user.id)
    share_user.read_state = new_state
    share_user.save
    
    respond_to do |format|
      format.js {"{'success': true}"}
    end
  end
end