class Mailer < ActionMailer::Base
  default :from => "amplifize@amplifize.com"

  def new_user_email(user)
    @User = user
    mail(:to => user.email, :subject => "Welcome to Amplifize!")
  end

  def new_follower_email(user, follower)
    @User = user
    @Follower = follower
    mail(:to => user.email, :subject => "You have a new follower on Amplifize!")
  end
  
end
