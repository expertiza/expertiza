module GoogleDocsHelper
  require 'gdata'

  def gdocs_authenticated
    if ! session[:google_docs_token] && params[:token]
	  puts "No session token, but there was a param token #{params[:token]}"
      client = GData::Client::DocList.new
      client.authsub_token = params[:token] # extract the single-use token from the URL query params
      session[:google_docs_token] = client.auth_handler.upgrade()
	  puts "Upgraded token to a session token #{session[:google_docs_token]}"
    end

	puts "Returning session token #{session[:google_docs_token]}"
    return session[:google_docs_token] != nil
  end

  def gdocs_authentication_link
    client = GData::Client::DocList.new
    #domain = 'example.com'  # force users to login to a Google Apps hosted domain
    next_url = request.url
    secure = false  # set secure = true for signed AuthSub requests
    sess = true
    authsub_link = client.authsub_url(next_url, secure, sess)

    return authsub_link
  end

end
