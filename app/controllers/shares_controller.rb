class SharesController < ApplicationController
  def add
    #Step 1 generate the share
    share = Share.create(
        :post_id      => params[:post_id],
        :user_id      => current_user.id,
        :summary      => params[:summary] 
    )

    puts "SharesController::add"
    followers = Follow.find_all_by_followed(current_user.id)

    if not followers.nil? then
      #Step 2 let all followers know
      followers.each do |follower|
        ShareUser.create(
          :share_id      => share.id,
          :user_id      => follower.id,
          :read_state   => 1
        )
      end
    end

    #Step 3 respond
    respond_to do |format|
      format.js { render :json => share }
    end
  end
end
