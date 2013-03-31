module Importer
  class <<self
    def do_import(user, feeds, tags)
      if !feeds.nil?
        feeds.each do |idx,url|
          Feed.setup_feed(user, url, tags[idx])
        end
      end
    end
    
    def do_import(user, feeds)
      if !feeds.nil?
        feeds.each do |feed|
          Feed.setup_feed(user, feed[:url], feed[:labels])
        end
      end
    end

    def split_subscribed_feeds(feeds,subscriptions)
      subscribed = Array.new
      unsubscribed = Array.new
      subscriptions.each do |subscription|
        if feeds.include?(subscription[:url])
          subscription[:subscribed] = true
        subscribed << subscription
        else
        unsubscribed << subscription
        end
      end

      {:subscribed => subscribed, :unsubscribed => unsubscribed}
    end
  end

  module OPML
    include Importer
    #extend Importer
    class <<self
      def load_feeds_from_file_upload(user, file)
        subscriptions = parse_data_from_file(file.tempfile)
        feeds = user.feeds.map(&:url)
        parent.split_subscribed_feeds(feeds,subscriptions)
      end

      def load_feeds_from_url(user, data)

      end

      private

      def parse_data_from_file(file)
        require 'Opml'
        opml_xml = Opml::Opml.new(file)

        subscriptions = Array.new
        opml_xml.outlines.each do |feed|
          url = feed.attributes['xml_url']
          title = feed.attributes['title']

          if not url.nil?
            subscriptions << {:url => url, :title => title, :subscribed => false, :labels => nil}
          else
            tag = feed.attributes['title']
            feed.outlines.each do |feed_in_folder|
              url = feed_in_folder.attributes['xml_url']
              title = feed_in_folder.attributes['title']
              subscriptions << {:url => url, :title => title, :subscribed => false, :labels => [tag]}
            end
          end

        end
        subscriptions
      end
    end
  end

  module Google
    include Importer
    class <<self
      def load_feeds(user, oauth)

        url = "http://www.google.com/reader/api/0/subscription/list?output=json"
        data = oauth.get_for_url(:google, url)

        feeds = user.feeds.map(&:url)
        subs = parse_data(data)
        parent.split_subscribed_feeds(feeds,subs)
      end

      private

      def parse_data(data)
        subscriptions = Array.new

        begin
          obj = JSON.parse(data)
          if obj['subscriptions'].nil?
            raise "Error parsing Google Reader data.  Subscription block not available."
          end
        rescue => e
          raise GoogleDataParseError, "Error parsing Google Reader data.: #{e.message}"
        end

        obj['subscriptions'].each do |sub|
          labels = nil
          if sub['categories']
            labels = Array.new
            sub['categories'].each do |category|
              labels << category['label']
            end
          end
          subscriptions << {:url => sub['id'][5..-1], :title => sub['title'], :subscribed => false, :labels => labels}
        end

        subscriptions
      end
    end
  end

  class GoogleDataParseError < StandardError
  end
end