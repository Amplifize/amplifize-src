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

  def new_follower_email(user, follower)
    @User = user
    @Follower = follower
    mail(:to => user.email, :subject => "You have a new follower on Amplifize!")
  end
  
  def invite_friend_email(invite)
    @Invite = invite
    mail(:to => invite.email, :subject => "#{@Invite.user.visible_name} has invited you to join Amplifize!")
  end
  
end
