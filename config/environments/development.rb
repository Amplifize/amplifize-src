Salon::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_view.debug_rjs             = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin
  
  # Default domain name for URLs generated with the mailer
  config.action_mailer.default_url_options = { :host => "amplifize.local", :port => 3000 }
  
  # Configurations for Action Mailer
  config.action_mailer.delivery_method = :file
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true
  
  # Configuration for OAuth2 token providers
  config.oauth2 = {
    :google => {
      :amplifize_service_id => 1,
      :client_id => "959866842432.apps.googleusercontent.com",
      :client_secret => "cVhbsQAEkIVolv3F6XhQ9gDi",
      :redirect_uri => "http://localhost:3000/oauth2/callback",
      :scope => "http://www.google.com/reader/api/0/subscription/list",
      :authorize_url => "https://accounts.google.com/o/oauth2/auth",
      :token_url => "https://accounts.google.com/o/oauth2/token"
    }
  }

  
end

