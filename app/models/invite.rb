# Model for handling Friend Invitations
class Invite < ActiveRecord::Base
  belongs_to :user
  def self.create(user, emails, message)

    # Iterate through the emails to invite each one
    emails.each do |email|
      invited_user = User.find_by_email(email)
      # If the invited user does not exist, then create and send the invite
      if invited_user.nil?

        invite = Invite.new
        invite.user = user
        invite.uid = SecureRandom.hex()
        invite.email = email
        invite.message = message
        invite.save

        Mailer.delay.invite_friend_email(invite)
      else
      # User already exists.  Automatically follow
        Follow.follow_user(user, invited_user, true)
      end
    end

  end

  # Handles new users that were created from
  # an invite.  This includes following the user
  # that invited them and deleting the invitation
  def self.handle_new_user(invite_uid, new_user)

    invite = Invite.find_by_uid(invite_uid)
    if not invite.nil?
      Follow.create_bidirectional(new_user, invite.user, true)
    invite.destroy
    end

  end
end
