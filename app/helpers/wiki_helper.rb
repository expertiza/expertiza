require 'open-uri'
#require 'date'
require 'time'
#NOTE: Use time instead of date for speed reasons. See:
#http://www.recentrambles.com/pragmatic/view/33


module WikiHelper

  #TODO:
  #1) Add new args for User & Date
  def review_dokuwiki(_assignment_url, _start_date = nil)

    response = '' #the response from the URL

    #Check to make sure we were passed a valid URL
    matches = /http:/.match( _assignment_url )
    if not matches
      return response
    end

    #Args
    url = _assignment_url
    wiki_url = _assignment_url.scan(/(.*?)dokuwiki/)
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

    #Clean URLs
    response = response.gsub(/\/dokuwiki/,wiki_url[0].to_s + 'dokuwiki')

    # Luckily, dokuwiki uses a structure like:
    # <!-- wikipage start -->  
    # Content
    # <!-- wikipage stop -->
    # 
    changes = response.split(/wikipage/) #Get everything between the words "wikipage"
    changes = changes[1].sub(/start -->/,"") #Trim the "start -->" from "<!-- wikipage start -->"
    response = changes.sub(/<!--/,"") #Trim the "<!--" from "<!-- wikipage stop -->"

    #Extract each date line item
    date_lines = response.scan(/<li>(.*?)<\/li>/)

    #if start date provided we only want date line items since start date
    if _start_date
      
      #Extract the dates only
      dates = response.scan(/\d\d\d\d\/\d\d\/\d\d \d\d\:\d\d/) 

      #NOTE: The date_lines index = dates index
    
      #Convert _start_date
      start_date = Time.parse(_start_date)

      #Remove dates before deadline
      dates.each_with_index do |date, index| 

          #The date is before start of review
          if Time.parse(date) < start_date
            date_lines.delete_at(index)
          end

      end

    end
    
    #TODO
    # Show only this users changes

    return date_lines
  end


end
