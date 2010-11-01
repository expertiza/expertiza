module GoogleDocsHelper
  require 'gdata'

  # Indicates whether a user is authenticated to use Google Docs APIs
  # or not.  This is accomplished by checking the session for specific
  # Google Docs tokens.
  def gdocs_authenticated
    if ! session[:google_docs_token] && params[:token]
      #puts "No session token, but there was a param token #{params[:token]}"

      # Create a new client
      client = GData::Client::DocList.new

      # Set the token to the one from the session
      # extract the single-use token from the URL query params
      client.authsub_token = params[:token]

      # Upgrade the single user token to a full session one
      session[:google_docs_token] = client.auth_handler.upgrade()

      #puts "Upgraded token to a session token #{session[:google_docs_token]}"
    end

    #puts "Returning session token #{session[:google_docs_token]}"
    return session[:google_docs_token] != nil
  end

  # Generate a link a view can use to authenticate Expertiza with the
  # Google Docs API
  def gdocs_authentication_link
    # Create a new client
    client = GData::Client::DocList.new

    #domain = 'example.com'  # force users to login to a Google Apps hosted domain
    next_url = request.url
    secure = false  # set secure = true for signed AuthSub requests
    sess = true

    # Generate the link
    authsub_link = client.authsub_url(next_url, secure, sess)

    return authsub_link
  end

end
