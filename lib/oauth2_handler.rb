######################
#
# Simple implementation for getting
# OAuth2 auth and access tokens plus
# using OAuth2 tokens to access authenticated
# resources.
#
# This implementation is persistent only for the
# current session.  Users must re-request OAuth2
# credentials if (1) they logout or (2) the token
# expires.  The implementation does not attempt to
# make use of refresh tokens.
#
# Individual services are configured in
# the environment's configuration file
# (development.rb, production.rb).  See config.oauth2
#
#######################
class OAuth2_Handler
  # Initializes the handler for a given Rails session
  def initialize(session)
    set_session(session)
    cleanup_expired_tokens
  end

  # Returns if the current session is authorized
  def is_authorized?(service)
    service_tokens = get_service_tokens(service)

    # check that the token has been set
    if service_tokens.nil? || service_tokens[:access_token].nil?
    return false
    end

    return true
  end

  # Returns the URL to request an OAuth2 authorization
  # token from a provider.  Includes a unique request
  # id used to identify this request on callback
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

  # Calls the OAuth2 auth token's provider to
  # authorize the request and get a private
  # access token used for requests to a resource
  def authorize_token(request)
    
    request_id = request[:state]
    auth_token = request[:code]
    error = request[:error]
    
    puts auth_token
    
    if auth_token.nil? || error
      raise OAuth2AccessDeniedError.new("No authorization token provided", error)
    end
    
    if request_id.nil? || @requests[request_id].nil?
      raise OAuth2InvalidRequestError, "Callback request ID is invalid"
    end
    
    service = @requests[request_id]
    @services[service] = request_access_token(service,auth_token)
    @requests.delete(request_id)
  end

  # Does an HTTP GET for the given URL, appending
  # the current OAuth2 access token for the specified
  # service to the query string
  def get_for_url(service, url)

    access_token = get_access_token(service)

    append_char = "?"
    if !url.index(append_char).nil?
      append_char = "&"
    end

    url_to_send = String.new
    url_to_send << url
    url_to_send << append_char
    url_to_send << "access_token="
    url_to_send << access_token

    content = nil
    sender = Curl::Easy.new(url_to_send) do |curl|
      curl.on_success do |c|
        content = c.body_str
      end
    end
    sender.http_get

    if (content.nil?)
      raise OAuth2HttpError.new("No data received", sender.response_code)
    end
    content
  end

  private

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
    end

    sender.http_post(post_data)

    if content.nil?
      raise OAuth2HttpError.new("No data received", sender.response_code)
    end
    
    begin
      response_object = JSON.parse(content)

      if response_object.nil? || response_object['access_token'].nil?
        raise "Error parsing OAuth2 response. Token not available in response."
      end
    rescue => e
      raise OAuth2TokenError, "Error getting access token.  #{e.message}"
    end

    access_token = response_object['access_token']

    expire_time = nil
    if not response_object['expires_in'].nil?
      expire_time = Time.now + response_object['expires_in'].seconds-300.seconds
    end

    {:access_token => access_token, :expire_time => expire_time}
  end

  def get_access_token(service)
    if !is_authorized?(service)
      raise OAuth2NotAuthorizedError, "User is not authorized for service #{service}"
    end

    service_tokens = get_service_tokens(service)
    service_tokens[:access_token]
  end

  def set_session(session)
    @session = session
    if @session[:oauth2].nil?
      @session[:oauth2] = {:requests => {}, :services => {}}
    end

    @requests = @session[:oauth2][:requests]
    @services = @session[:oauth2][:services]
  end

  def cleanup_expired_tokens
    @services.each do |key,value|
      token = @services[key]
      if !token[:expire_time].nil? && token[:expire_time] <= Time.now
      @services.delete(key)
      end
    end
  end

  def get_request_token(service)
    token = SecureRandom.hex()
    @requests[token] = service
    token
  end

  def get_service_config(service)
    configs = Rails.application.config.oauth2
    if configs.nil? || configs[service].nil?
      raise OAuth2ServiceNotConfiguredError, "Service #{service} not configured"
    end
    configs[service]
  end

  def get_service_tokens(service)
    @services[service]
  end

end

class OAuth2HttpError < StandardError
  attr :response_code
  def initialize(message,code)
    super(message)
    @response_code = code
  end
end

class OAuth2AccessDeniedError < StandardError
  attr :error_code
  def initialize(message,error_code)
    super(message)
    @error_code = error_code
  end
end

class OAuth2TokenError < StandardError
end

class OAuth2ServiceNotConfiguredError < StandardError
end

class OAuth2InvalidRequestError < StandardError
end

class OAuth2NotAuthorizedError < StandardError
end