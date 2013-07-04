class ImportController < ApplicationController
  before_filter :require_user
  
  def import
    #static page from which to import feeds
  end

  def do_import
    require_dependency 'importer'

    feeds = params[:feeds]
    tags = params[:tags]

    if not feeds.nil?
      Importer.do_import(current_user,feeds,tags)
      @success = true
    end
  end

  def do_import(feeds)
    if not feeds.nil?
      Importer.do_import(current_user,feeds)
      @success = true
    end
  end

  def opml
    require_dependency 'importer'

    if params[:import]
      if !params[:import][:opml_file].nil?
        #importer = Importer::OPML.new
        uploaded_file = params[:import][:opml_file]
        subscriptions = Importer::OPML.load_feeds_from_file_upload(current_user,uploaded_file)

        @subscribed = subscriptions[:subscribed]
        @unsubscribed = subscriptions[:unsubscribed]

        do_import(@unsubscribed)

        puts "Doing OPML File Import"
      else
        puts "Unknown OPML Import"
      end
    end

    respond_to do |format|
      format.html { render :template => 'import/finish' }
    end
  end
end
