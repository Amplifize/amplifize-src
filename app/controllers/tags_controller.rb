class TagsController < ApplicationController
  def create
    tags = params[:tag][:name].squish().split(",")
    return_tags = Hash.new
    tags.each do |tag|
      return_tags[tag] = Tag.create!(
        :user_id => current_user.id,
        :feed_id => params[:tag][:feed_id],
        :name => tag.squish()
      )
    end

    respond_to do |format|
      format.js { render :json => {"feed_id" => params[:tag][:feed_id], "tags" => return_tags}}
    end
  end
  
  def destroy
    Tag.delete(params[:id])
    
    respond_to do |format|
      format.js { render :json => '{"success": true}' }
    end
  end
end
