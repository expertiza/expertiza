require 'open-uri'
#require 'date'
require 'time'
#NOTE: Use time instead of date for speed reasons. See:
#http://www.recentrambles.com/pragmatic/view/33


module WikiHelper


  def review_dokuwiki(_assignment_url, _start_date = nil, _wiki_user = nil)

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
    review = "?do=revisions" #"?do=recent"

    url += review

    open(url, 
         "User-Agent" => "Ruby/#{RUBY_VERSION}",
         "From" => "email@addr.com", #Put pg admin email address here
         "Referer" => "http://") { |f| #Put pg URL here
      
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
    #Get everything between the words "wikipage"
    changes = response.split(/wikipage/) 
    #Trim the "start -->" from "<!-- wikipage start -->"
    changes = changes[1].sub(/start -->/,"") 
    #Trim the "<!--" from "<!-- wikipage stop -->"
    response = changes.sub(/<!--/,"") 


    #Extract each line item
    line_items = response.scan(/<li>(.*?)<\/li>/)

    #Extract the dates only
    dates = response.scan(/\d\d\d\d\/\d\d\/\d\d \d\d\:\d\d/) 


    #if wiki username provided we only want their line items
    if _wiki_user
   
      #Remove line items that do not contain this user
      line_items.each_with_index do |item, index| 

        scan_result = item[0].scan(_wiki_user) #scan current item

        if not _wiki_user === scan_result[0] #no match for wiki user --> eliminate
          line_items[index] = nil  
          dates[index] = nil
        end

      end

      line_items.compact!
      dates.compact!
    end


    #if start date provided we only want date line items since start date
    if _start_date
      

      #NOTE: The date_lines index = dates index
    
      #Convert _start_date
      start_date = Time.parse(_start_date)

      #Remove dates before deadline
      dates.each_with_index do |date, index| 

          #The date is before start of review
          if Time.parse(date) < start_date
            line_items.delete_at(index)
          end

      end

    end
    

    return line_items

  end


end
