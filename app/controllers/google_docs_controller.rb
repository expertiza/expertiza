class GoogleDocsController < ApplicationController
    helper :google_docs
    include GoogleDocsHelper
    helper_method :gdocs_authenticated

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

  def documents
    if ( gdocs_authenticated )
      client = GData::Client::DocList.new
      client.authsub_token = session[:google_docs_token]
      feed = client.get('http://docs.google.com/feeds/documents/private/full').to_xml
      docs = Array.new
      feed.elements.each('entry') do |entry|
        # Extract the href value from each <atom:link>
        links = {}
        entry.elements.each('link') do |link|
          if ( link.attribute('rel').value.index(/\//) )
            # puts "Dropping link because it's rel is [#{link.attribute('rel').value}"
          else
            links[link.attribute('rel').value] = link.attribute('href').value
          end
        end
        document_type = 'generic'
        entry.elements.each('category') do |category|
          if category.attribute('scheme').value.eql? "http://schemas.google.com/g/2005#kind"
            document_type = category.attribute('label').value
          end
        end
        docs << {
          :id => entry.elements['id'].text,
          :title => entry.elements['title'].text, 
          :document_type => document_type,
          :updated => entry.elements['updated'].text,
          :links => links
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

end
