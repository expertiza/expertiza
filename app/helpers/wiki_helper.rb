require 'open-uri'

module WikiHelper

  #TODO:
  #1) Add new args for User & Date
  def review_dokuwiki(assignment_dir)

    response = '' #the response from the URL

    #Check to make sure we were passed a valid URL
    matches = /http:/.match( assignment_dir )
    if not matches
      return response
    end

    #Args
    url = assignment_dir
    #unity_id = 

    #Doku Wiki Specific
    review = "?do=recent"

    url += review

    open(url, 
         "User-Agent" => "Ruby/#{RUBY_VERSION}",
         "From" => "email@addr.com",
         "Referer" => "http://") { |f|
      
      #puts "Source URL: #{f.base_uri}"
      #puts "\t Last Modified: #{f.last_modified}\n\n"

      # Save the response body
      response = f.read
      
    }

    ## DOKUWIKI PARSING
    # Luckily, dokuwiki uses a structure like:
    # <!-- wikipage start -->  
    # Content
    # <!-- wikipage stop -->
    # 
    changes = response.split(/wikipage/) #Get everything between the words "wikipage"
    changes = changes[1].sub(/start -->/,"") #Trim the "start -->" from "<!-- wikipage start -->"
    response = changes.sub(/<!--/,"") #Trim the "<!--" from "<!-- wikipage stop -->"

    #Clean Up HTMAL
    response['<h1><a name="recent_changes" id="recent_changes">Recent Changes</a></h1>'] = '<h3>Recent Wiki Changes</h3>'
    #TODO
    # Update links with absolute path not relative
    # Show only this users changes
    # Show only changes from date arg

    return response
  end


end
