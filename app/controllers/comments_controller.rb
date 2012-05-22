class CommentsController < ApplicationController
  def create
    comment = Comment.create(
      :share_id => params[:comment][:share_id],
      :user_id => current_user.id,
      :comment_text => params[:comment][:comment_text]
    )

    shares = ShareUser.find_all_by_share_id_and_read_state(params[:share_id], 0)
    if not shares.nil? then
      shares.each do |share|
        share.read_state = 1
        share.commit
      end
    end

    respond_to do |format|
      format.js {render :json => comment}
    end
  end
end
