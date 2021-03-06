class Mailer < ActionMailer::Base
  default :from => "\"Amplifize\" <support@amplifize.com>"

  def new_user_email(user)
    @title = "Welcome to the conversation on Amplifize"
    @preview = "Use this email to help you get started with Amplifize"
    @User = user
    mail(:to => user.email, :subject => @title) do |format|
      format.html { render :layout => 'email_layout' }
    end
  end

  def new_follower_email(follows, current_user)
    @current_user_name = current_user.display_name.nil? ? current_user.email : current_user.display_name
    @current_user_id = current_user.id
    @am_following = Follow.exists?(:user_id => follows.id, :follows => current_user.id)
    
    @title = "Someone new has joined your conversations!"
    @preview = @current_user_name + " has started to follow your conversations on Amplifize"
    mail(:to => follows.email, :subject => @title) do |format|
      format.html {render :layout => 'email_layout' }
    end
  end
  
  def invite_friend_email(invite)
    @Invite = invite
    mail(:to => invite.email, :subject => "Join the conversation with #{@Invite.user.visible_name} on amplifize!") do |format|
      format.html {render :layout => 'email_layout'}
    end
  end
  
  def forgot_password_email(user)
    @reset_url = edit_password_reset_url(user.perishable_token)
    mail(:to => user.email, :subject => "Reset your amplifize password") do |format|
      format.html {render :layout => 'email_layout'}
    end
  end
end
