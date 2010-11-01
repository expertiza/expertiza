class GoogleDocsController < ApplicationController
  helper :google_docs
  include GoogleDocsHelper
  helper_method :gdocs_authenticated

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

  # Return a list of documents via the Google Docs APIs.
  def documents
    # Check that we are authenticated
    if ( gdocs_authenticated )
      # Create a new client
      client = GData::Client::DocList.new

      # Set the token from the session
      client.authsub_token = session[:google_docs_token]

      # Point the client at the document feed
      feed = client.get('http://docs.google.com/feeds/documents/private/full').to_xml

      # Create a new Array to return
      docs = Array.new

      # Iterate over each element within the result set
      feed.elements.each('entry') do |entry|

        # Extract the href value from each <atom:link>
        links = {}
        entry.elements.each('link') do |link|
          # puts link
          if ( link.attribute('rel').value.index(/\//) )
            # puts "Dropping link because it's rel is [#{link.attribute('rel').value}"
          else
            links[link.attribute('rel').value] = link.attribute('href').value
          end
        end

        # This is future code for when the Google Docs APIs promotes v3
        # outside of Google Labs (eg out of beta).
        revisions = Array.new
        #revisions = get_revisions(entry.elements['gd:resourceId'].text)
        
        # Set the default document type to generic, just in case we can't
        # figure it out.  After that iterate over each category element
        # looking for the 'kind' scheme.
        document_type = 'generic'
        entry.elements.each('category') do |category|
          if category.attribute('scheme').value.eql? "http://schemas.google.com/g/2005#kind"
            document_type = category.attribute('label').value
          end
        end

        # Append the current document structure to the result
        docs << {
          :id => entry.elements['id'].text,
          :title => entry.elements['title'].text, 
          :document_type => document_type,
          :updated => entry.elements['updated'].text,
          :content => entry.elements['content'].attribute('src').value,
          :links => links,
          :revisions => revisions
        }
      end

      respond_to do |format|
        format.html # documents.html.erb
        format.xml { render :xml => docs }
      end
    else
      flash[:error] = "Not authenticated with Google Docs"
      respond_to do |format|
        format.html # documents.html.erb
        format.xml { head :failure }
      end
    end
  end

  # Probably shouldn't be in the controller...
  # This method will only work with Google Docs Protocol 3.0 or higher.  This
  # is currently in Google Labs and not generally available.
  def get_revisions(resourceId)
    revisions = Array.new
    if ( gdocs_authenticated )
      client = GData::Client::DocList.new
      client.authsub_token = session[:google_docs_token]
      puts "Requesting: http://docs.google.com/feeds/default/private/full/#{resourceId}/revisions"
      feed = client.get("http://docs.google.com/feeds/default/private/full/#{resourceId}/revisions").to_xml
      feed.elements.each('entry') do |entry|
        revisions << {
          :title => entry.elements['entry'].text,
          :updated => entry.elements['updated'].text,
          :content => entry.elements['content'].attribute('src').value
        }
      end
    end
    return revisions
  rescue
    return Array.new
  end

end
