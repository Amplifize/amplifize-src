class Mailer < ActionMailer::Base
  default :from => "amplifize@amplifize.com"

  def new_user_email(user)
    @User = user
    mail(:to => user.email, :subject => "Welcome to Amplifize!")
  end
  
end
