Amplifize::Application.routes.draw do

  match '/login' => 'user_sessions#create', :as => :login
  match '/logout' => 'user_sessions#destroy', :as => :logout
  match '/register' => 'users#create', :as => :signup

  #part of the Google Reader import process
  match '/oauth2/callback' => 'user_sessions#oauth2_response', :as => :oauth2_response
  match '/oauth2/request/:service' => 'user_sessions#oauth2_request', :as => :oauth2_request

  #Logged in state pages
  match '/my/homepage' => 'users#homepage', :as => :homepage
  match '/my/content' => 'users#content', :as => :content
  match '/my/conversations' => 'users#conversations', :as => :conversations
  match '/my/people' => 'users#reader', :as => :people

  match '/my/profile' => 'users#profile', :as => :profile, :via => :get
  match '/my/profile/' => 'users#update', :as => :update_profile, :via => :post

  #People actions
  match '/users/search' => 'users#search', :as => :user_search

  #Import 3rd-party content stack
  match '/feeds/import' => 'import#import', :as => :import
  match '/feeds/import/import' => 'import#do_import', :as => :import_import
  match '/feeds/import/google' => 'import#google', :as => :import_google
  match '/feeds/import/opml' => 'import#opml', :as => :import_opml

  #Feed based actions
  match '/my/feeds/' => 'feeds#manage', :as => :feeds_manage

  match '/feeds/clear-all' => 'feeds#clearAll'
  match '/feeds/:feed_id/tags' => 'feeds#tagsByFeed'
  match '/feeds/:feed_id/unsubscribe/' => 'users#unsubscribe', :as => :unsubscribe

  match '/post_users/:post_id/read_state/:state', :controller => 'post_users', :action => 'set_read_state'
  match '/share_users/:share_id/read_state/:state', :controller => 'share_users', :action => 'set_read_state'

  #Share bookmarklet actions
  match '/ext/share/prompt(/:api_version)/:user_credentials' => 'bookmarklet#share_prompt', :as => :ext_share_prompt
  match '/ext/share/:api_version/:user_credentials' => 'bookmarklet#share', :as => :ext_share

  #Subscribe bookmarklet actions
  match '/ext/sub(/:api_version)/:user_credentials' => 'bookmarklet#sub', :as => :ext_sub

  #follows actions
  match '/follows/:user_id/add' => 'follows#add', :as => :follows_add
  match '/follows/:user_id/unsubscribe' => 'follows#unsubscribe', :as => :unsubscribe_person

  #share actions
  match '/shares/add/' => 'shares#add', :as => :shares_add

  #invite actions
  match '/invite/create' => 'invite#create', :as => :invite_create
  match '/invite/respond/:invite_id' => 'invite#respond', :as => :invite_respond

  match '/about' => 'home#about', :as => :about
  match '/about/team' => 'home#team'
  match '/about/why-amplifize' => 'home#why_amplifize'
  match '/contact' => 'home#contact', :as => :contact
  match '/terms' => 'home#terms', :as => :terms
  match '/faq' => 'home#faq', :as => :faq

  match '/googleaf23107439d49301.html' => 'home#google_verification'

  resources :users, :user_sessions, :feeds, :posts, :shares, :comments, :tags, :invites

  root :to => "home#index"

end
