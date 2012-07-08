module Importer
  class <<self
    def do_import(user, feeds, tags)
      if !feeds.nil?
        feeds.each do |idx,url|
          Feed.setup_feed(user, url, tags[idx])
        end
      end
    end

  end

  module Google
    class <<self
      def load_feeds(user, oauth)

        url = "http://www.google.com/reader/api/0/subscription/list?output=json"
        data = oauth.get_for_url(:google, url)

        feeds = user.feeds.map(&:url)
        subs = parse_data(data)
        split_subscribed_feeds(feeds,subs)
      end

      private

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

    class GoogleDataParseError < StandardError
    end
  end
end