Amplifize::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Raise exception on mass assignment protection for Active Record models
  config.active_record.mass_assignment_sanitizer = :strict

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  config.active_record.auto_explain_threshold_in_seconds = 0.5

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

  # Default domain name for URLs generated with the mailer
  config.action_mailer.default_url_options = { :host => "amplifize.local", :port => 3000 }

  config.show_support_widget = false

  # Configurations for Action Mailer
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true

  config.action_mailer.smtp_settings = {
    :user_name => "amplifize",
    :password => "b1gFi$hBiGp0Nd",
    :domain => "amplifize.com",
    :address => "smtp.sendgrid.net",
    :port => 587,
    :authentication => :plain,
    :enable_starttls_auto => true
  }

  # Configuration for OAuth2 token providers
  config.oauth2 = {
    :google => {
      :amplifize_service_id => 1,
      :client_id => "243455842448-1l1m38cdobel9cvntms6i0h263vhbvbt.apps.googleusercontent.com",
      :client_secret => "LJWC1V1I1yi9Xe-BdfxRwzZJ",
      :redirect_uri => "http://localhost:3000/oauth2/callback",
      :scope => "http://www.google.com/reader/api/0/subscription/list",
      :authorize_url => "https://accounts.google.com/o/oauth2/auth",
      :token_url => "https://accounts.google.com/o/oauth2/token"
    }
  }

end
