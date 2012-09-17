class CommentsController < ApplicationController
  def create
    comment = Comment.create(
      :share_id => params[:comment][:share_id],
      :user_id => current_user.id,
      :comment_text => params[:comment][:comment_text]
    )

    ShareUser.update_all("read_state = 1", ["share_id = ? AND read_state = 0 AND user_id != ?", params[:comment][:share_id], current_user.id ])

    respond_to do |format|
      format.js {render :json => comment.to_json(
        :include => {
          :user => {}
        }
      )}
    end
  end
end
