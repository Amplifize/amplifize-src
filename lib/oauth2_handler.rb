class OAuth2_Handler
  @@oauth2_configs = Rails.application.config.oauth2

  def initialize(session)
    set_session(session)
    cleanup_expired_tokens
  end
  
  def cleanup_expired_tokens
    @services.each do |key,value|
      token = @services[key]
      if !token[:expire_time].nil? && token[:expire_time] <= Time.now
        @services.delete(key)
      end
    end
  end
  
  def set_session(session)
    @session = session
    if @session[:oauth2].nil?
      @session[:oauth2] = {:requests => {}, :services => {}}
    end
    
    @requests = @session[:oauth2][:requests]
    @services = @session[:oauth2][:services]
  end

  def get_service_config(service)
    if @@oauth2_configs.nil? || @@oauth2_configs[service].nil?
      raise "Service not configured"
    end
    @@oauth2_configs[service]
  end

  def get_service_tokens(service)
    @services[service]
  end

  def is_authorized?(service)
    service_tokens = get_service_tokens(service)
    
    # check that the token has been set
    if service_tokens.nil? || service_tokens[:access_token].nil?
      return false
    end

    return true
  end
  
  def get_request_token(service)
    token = SecureRandom.hex()
    @requests[token] = service
    token
  end

  def get_auth_url(service)
    config = get_service_config(service)
    request_id = get_request_token(service)

    url = String.new
    url << config[:authorize_url]
    url << "?response_type=code"
    url << "&client_id="
    url << config[:client_id]
    url << "&redirect_uri="
    url << config[:redirect_uri]
    url << "&scope="
    url << config[:scope]
    url << "&state="
    url << request_id

    url
  end

  def authorize_token(request_id,auth_token)
    service = @requests[request_id] 
    @requests.delete(request_id)
    
    if service.nil?
      raise "Error - No Request ID Available"
    end

    @services[service] = request_access_token(service,auth_token)
  end

  def get_url_content(service,url)

  end

  def get_access_token(service)
    if !is_authorized?(service)
      raise "Error:  service not authorized"
    end
    
    service_tokens = get_service_tokens(service)

    service_tokens[:access_token]
  end
    
  def request_access_token(service,auth_token)

    config = get_service_config(service)

    url = config[:token_url]

    post_data = String.new
    post_data << "grant_type=authorization_code"
    post_data << "&code="
    post_data << auth_token
    post_data << "&client_id="
    post_data << config[:client_id]
    post_data << "&client_secret="
    post_data << config[:client_secret]
    post_data << "&redirect_uri="
    post_data << config[:redirect_uri]

    content = nil
    sender = Curl::Easy.new(url) do |curl|
      curl.on_success do |c|
        content = c.body_str
      end

      curl.on_complete do |c|
      end
    end

    sender.http_post(post_data)
    if !content.nil?
      response_object = JSON.parse(content)
      
      puts response_object.to_yaml
      
      access_token = response_object['access_token']
      expire_time = Time.now + response_object['expires_in'].seconds-300.seconds
      
      return {:access_token => access_token, :expire_time => expire_time}
    else 
      raise "Error getting access token"
    end
  end

  def get_for_url(service, url, query_string)
  
    access_token = get_access_token(service)

    if query_string.nil? then
      query_string = String.new
    else
      query_string << "&"
    end
    query_string << "access_token=#{access_token}"
    
    url_to_send = String.new
    url_to_send << url
    url_to_send << "?"
    url_to_send << query_string

    content = nil
    sender = Curl::Easy.new(url_to_send) do |curl|
      curl.on_success do |c|
        content = c.body_str
      end

      curl.on_complete do |c|
      end
    end
    sender.http_get

    content
  end

end