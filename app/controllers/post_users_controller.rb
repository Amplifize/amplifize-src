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

  # Marks all posts for a given feed with the given state
  # * If no feed_id is supplied, then all posts for the user are set to the state ("mark all as read")
  # * State will be set to 1 (unread) iff the state param is equal to '1'.  Otherwise, state will be 0 (read)
  def mark_all_read
    feed_id = params[:feed_id]
    state = params[:state]
    new_state = 0
    if state == '1'
      new_state = 1
    end
    
    if feed_id.nil? then
      PostUser.where(:user_id => current_user.id).update_all(:read_state => new_state)
    else
      PostUser.joins(:post => [:feed]).where(:feeds => {:id => feed_id}, :post_users => {:user_id => current_user.id}).update_all(:read_state => new_state)
    end

    respond_to do |format|
      format.js {"{'success': true}"}
    end
  end
end