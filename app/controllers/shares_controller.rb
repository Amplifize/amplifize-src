class SharesController < ApplicationController
  before_filter :require_user

  def single_access_allowed?
    (action_name == "add_remote")
  end

  def add
    #Step 1 generate the share
    share = Share.create(
      :post_id      => params[:postId],
      :user_id      => current_user.id,
      :summary      => params[:summary]
    )

    followers = Follow.find_all_by_follows(current_user.id)

    if not followers.nil? then
      #Step 2 let all followers know
      followers.each do |follower|
        ShareUser.create(
          :share_id      => share.id,
          :user_id      => follower.user_id,
          :read_state   => 1
        )
      end
    end

    #Step 3 respond
    respond_to do |format|
      format.js { render :json => share }
    end
  end

  def add_remote
    
  end

  def show
    share = Share.find_by_id(params[:id])

    respond_to do |format|
      format.js {render :json => share.to_json(
        :include => {
          :comments => {
            :include => :user
          },
          :post => {
            :include => :feed
          },
          :user => {}
        }
      )}
    end
  end

  def byFollows
    shares = current_user.shares.where("shares.user_id = ?", params[:followsId]).unread.desc
    if shares.nil? then
      shares = []
    end
    
    respond_to do |format|
      format.js {render :json => shares.map(&:id).to_json}
    end
  end
end
