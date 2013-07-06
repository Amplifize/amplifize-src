class Follow < ActiveRecord::Base
  belongs_to :users
  
  # Creates a new follow for two users. Optionally send an email notifying
  # the followed user of a new follower
  def self.follow_user(user, user_to_follow, email = true)
    success = false
    follow = Follow.find_or_initialize_by_user_id_and_follows(user.id, user_to_follow.id)
    if not follow.persisted? then
      success = follow.save
      if email
        Mailer.delay(:queue => 'mail').new_follower_email(user_to_follow, user)
      end
    end
    success
  end
  
  # Creates a bi-directional follow relationship between
  # two users
  def self.create_bidirectional(user1, user2, email = true)
    Follow.follow_user(user1,user2,email)
    Follow.follow_user(user2,user1,email)
  end
end
