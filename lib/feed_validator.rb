class FeedValidator
  
  def self.normalize_protocol(url)
    if url[0..3] == "feed"
      url = "http" + url[4..-1]
    elsif url["://"].nil?
      url = "http://" + url
    end
    url
  end
  
  def self.extract_domain_from_url(url)
    URI.parse(url).host
  end
  
  def self.normalize_path(base_url, new_url)
    if (!URI.parse(new_url).relative?) 
      return new_url
    end
    URI.join(normalize_protocol(base_url), new_url).to_s
  end
  
  def self.get_feeds_from_html(url,content)
    doc = Nokogiri::HTML(content)
    
    query = '//link[contains(@type, "application/atom+xml") or contains(@type, "application/rss+xml")]'
    query << '|//a[contains(@type, "application/rss+xml") or contains(@type, "application/atom+xml")]'

    feeds = []
    doc.xpath(query).each do |meta|
      feeds << normalize_path(url, meta[:href])
    end
    
    feeds   
  end
  
  def self.get_feed_urls(url,depth = 0)
    urls = []
    options = {}
    options[:on_failure] = 
      lambda {|url, response_code, response_header, response_body| 
        if response_code == 200
          urls = urls + get_feeds_from_html(url,response_body)
        end }
    options[:on_success] = lambda {|url, feed_data| urls << feed_data.feed_url }
    options[:max_redirects] = 5

    Feedzirra::Feed.fetch_and_parse(url, options)
    
    urls
  end
  
  def self.validate_feed_url(url)
    url = normalize_protocol(url)
    existing_feed = Feed.find_by_url(url)
    if (!existing_feed.nil?)
      return [url]
    end
    get_feed_urls(url).uniq
  end
end

class FeedValidatorError < StandardError
end