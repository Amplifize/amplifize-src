require 'Twitter'

Twitter.configure do |config|
  config.consumer_key = "hk0a3x3oU28KLXCJEEPig"
  config.consumer_secret = "0gJqF5tYrUMyh8HgcJFtQhbtTgsVNuOeRIBOVKlTxo"
  config.oauth_token = "119266837-NvoGkC1tBUP51EZr50e8uvkFpcnV4GSbelim7lYO"
  config.oauth_token_secret = "l7GU4A64BQL2ZWbGuytSy0jwyPZkZt92UuoSw3ela8"
end

module TwitterWrapper
  class <<self
    def update_tweets
      puts "Updating..."
      puts Twitter.methods.to_yaml
    end

    def get_user_id_for_screen_name(screen_name)
      begin
        Twitter.user(screen_name).attrs["id"]
      rescue
        nil
      end
    end

    def get_screen_name_for_user_id(screen_name)
      begin
        Twitter.user(screen_name).attrs["screen_name"]
      rescue
        nil
      end
    end
  end
end