module ApplicationHelper
  #
  # Returns whether the user support widget should be 
  # displayed on the current page.  Currently only looks in 
  # env. configuration, but in future could be personalized
  # per user with a show/hide button
  #
  # @see environment#config.show_support_widget
  #
  def show_support_widget
    if not Rails.application.config.respond_to?(:show_support_widget)
      return true
    end
    Rails.application.config.show_support_widget
  end
end
