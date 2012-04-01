class PostsController < ApplicationController
  def show
    post = Post.find_by_id(params[:id])
    
    respond_to do |format|
      format.js {render :json => post.to_json(
        :include => {
          :feed => {}
        }
      )}
    end
  end
end