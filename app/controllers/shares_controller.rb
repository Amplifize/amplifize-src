class SharesController < ApplicationController
  before_filter :require_user

  def add    
    share = Share.add(params[:summary], params[:postId], current_user.id)

    respond_to do |format|
      format.js { render :json => share }
    end
  end

  def add_remote
    render :content_type => 'application/javascript'
  end

  def show
    share = Share.find_by_id(params[:id])

    respond_to do |format|
      format.js {render :json => share.to_json(
        :include => {
          :comments => { 
            :include => {
              :user => {:only => [:id, :email, :display_name]} 
             },
          },
          :post => {
            :include => :feed
          },
          :user => {:only => [:id, :email, :display_name] }
        }
      )}
    end
  end

  def byFollows
    shares = current_user.shares.where("shares.user_id = ?", params[:followsId]).unread.oldest_to_newest
    if shares.nil? then
      shares = []
    end
    
    respond_to do |format|
      format.js {render :json => shares.map(&:id).to_json}
    end
  end
end
