require 'open-uri'
require 'date'
require 'time'
#NOTE: Use time instead of date for speed reasons. See:
#http://www.recentrambles.com/pragmatic/view/33

##
# WikiHelper
#
# author: Jeffrey T. Haug
#
## 
module WikiHelper


  ##
  # review_dokuwiki
  #
  # author: Jeffrey T. Haug
  #
  # usage: To be used in a view such as:
  #
  # <%= review_dokuwiki 'http://pg-server.ece.ncsu.edu/dokuwiki/doku.php/ece633:hw1', '2007/06/11', 'jthaug'  %>
  #
  # @args: _assignment_url (URL of the wiki assignment.)
  # @args: _start_date (all review items older will be filtered out)
  # @args: _wiki_user (wiki user id to crawl)
  ##
  def self.review_dokuwiki(_assignment_url, _start_date = nil, _wiki_user = nil)

    response = '' #the response from the URL

    #Check to make sure we were passed a valid URL
    matches = /http:/.match( _assignment_url )
    if not matches
      return response
    end

    #Args
    url = _assignment_url.chomp("/")
    wiki_url = _assignment_url.scan(/(.*?)doku.php/)
    namespace = _assignment_url.split(/\//)
    namespace_url = namespace.last
    _wiki_user.gsub!(" ","+")

    #Doku Wiki Specific
    index = "?idx=" + namespace_url
    review = "?do=revisions" #"?do=recent"


    #Grab all relevant urls from index page ####################
    url += index
    open(url, 
         "User-Agent" => "Ruby/#{RUBY_VERSION}",
         "From" => "email@addr.com", #Put pg admin email address here
         "Referer" => "http://") { |f| #Put pg URL here
      
      # Save the response body
      response = f.read
      
    }

    #Clean URLs
    response = response.gsub(/href=\"(.*?)doku.php/, 'href="' + wiki_url[0].to_s + 'doku.php')

    #Get all URLs 
    index_urls = response.scan(/href=\"(.*?)\"/)
    
    namespace_urls = Array.new #Create array to store all URLs in this namespace
    namespace_urls << _assignment_url

    #Narrow down to all URLs in our namespace
    index_urls.each_with_index do |index_url, index| 
      
      scan_result = index_url[0].scan(_assignment_url + ":") #scan current item
      
      if _assignment_url + ":" === scan_result[0] 
        namespace_urls << index_urls[index].to_s 
      end
      
    end

    #Create a array for all of our review_items
    review_items = Array.new

    #Process Each page in our namespace
    namespace_urls.each_with_index do |cur_url, index| 
      
      #return cur_url + review
      url = namespace_urls[index].to_s 
      url += review
      #return url
      open(url, 
           "User-Agent" => "Ruby/#{RUBY_VERSION}",
           "From" => "email@addr.com", #Put pg admin email address here
           "Referer" => "http://") { |f| #Put pg URL here
        
        # Save the response body
        response = f.read
        
      }
      
      ## DOKUWIKI PARSING
      
      #Clean URLs
      response = response.gsub(/href=\"(.*?)doku.php/,'href="' + wiki_url[0].to_s + 'doku.php')
      
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
    

      review_items = review_items + line_items
      
    end

    return review_items
      

  end


  ##
  # review_mediawiki
  #
  # author: Jeffrey T. Haug
  #
  # usage: To be used in a view such as:
  #
  # <%= review_mediawiki 'http://pg-server.ece.ncsu.edu/mediawiki/index.php/ECE633:hw1', '2007/06/11', 'jthaug'  %>
  #
  # @args: _assignment_url (URL of the wiki assignment.)
  # @args: _start_date (all review items older will be filtered out)
  # @args: _wiki_user (wiki user id to crawl)
  ##
  def self.review_mediawiki(_assignment_url, _start_date = nil, _wiki_user = nil)
    
    response = '' #the response from the URL

    #Check to make sure we were passed a valid URL
    puts _assignment_url
    matches = /http:/.match( _assignment_url )
    if not matches
      return response
    end

    #Args
    url = _assignment_url.chomp("/")
    wiki_url = _assignment_url.scan(/(.*?)index.php/)
    namespace = _assignment_url.split(/\//)
    namespace_url = namespace.last
    _wiki_user.gsub!(" ","+")

    #Media Wiki Specific
    review = "index.php?limit=1000&tagFilter=&title=Special%3AContributions&contribs=user&target=" + _wiki_user+"&namespace=&year=&month=-1"
    #Grab this user's contributions
    url = wiki_url[0].to_s + review
    @urlin = url
    open(url, 
         "User-Agent" => "Ruby/#{RUBY_VERSION}",
         "From" => "email@addr.com", #Put pg admin email address here
         "Referer" => "http://") { |f| #Put pg URL here
      
      # Save the response body
      response = f.read
      @resp = response
    }

    #Clean URLs
    response = response.gsub(/href=\"(.*?)index.php/,'href="' + wiki_url[0].to_s + 'index.php')
    @res = response
    #Mediawiki uses a structure like:
    # <!-- start content -->  
    # Content
    # <!-- end content -->
    # 
    #Get everything between the words "wikipage"

    #changes = response.split(/<!-- start content -->/)
    #changes2 = changes[1].split(/<!-- end content -->/)
    #response = changes2[0]
    is_link_present = response.scan(/No changes were found matching these criteria/)
    if(is_link_present[0].nil? == false)
      return ""
    end
    #Extract each line item
    line_items = response.scan(/<li class=""><a href=".*?>/)
    latest_title = line_items[0].scan(/".*?"/)
    latest_title[2] = latest_title[2].gsub(/"/,'')
    latest_url = line_items[0].gsub(/&amp.*?"/,'"') + latest_title[2] +'</a></li>'
    #Extract the dates only
    dates = line_items[0].scan(/\d\d:\d\d, \d+ \w+ \d\d\d\d/)
    return latest_url
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


    #Remove line items that not in this namespace
    line_items.each_with_index do |item, index| 

      scan_result = item.scan(namespace_url)

      if not namespace_url === scan_result[0]
        line_items[index] = nil
      end

    end

    line_items.compact!
    
    # Only keep the most recently updated instance of each page
    pages = Array.new
    line_items_kept = Array.new
    
    line_items.each{|item|        
       urls = item.split("<a href=\"")
       #select the line containing the URL for the page
       pageArray = urls[3].split("\"") 
       # select the URL itself from the line of text
       # if it exists within the pages list, we don't need it
       # otherwise include it in the kept lines
       if !pages.index(pageArray[0])
         line_items_kept << item
         pages << pageArray[0]
       end
    }       
    line_items = line_items_kept    
    
    formatted_line_items =Array.new
    formatted_line_items << "<ul>"
    formatted_line_items << line_items
    formatted_line_items << "</ul>"
    return formatted_line_items

  end

  def self.compareDates(condition,dates,line_items)
      #Remove dates before deadline
      dates.each_with_index do |date, index|
        #The date is before start of review
        if (condition.call(date))
          line_items[index] = nil
        end
      end
  end
  def self.getwikipage(url)
    response = ''
    open(url,
         "User-Agent" => "Ruby/#{RUBY_VERSION}",
         "From" => "email@addr.com", #Put pg admin email address here
         "Referer" => "http://") { |f| #Put pg URL here
         # Save the response body
         response = f.read
         @resp = response
        }
    return response
  end
  def self.cleanURLS(response , wiki_url)
    return response.gsub(/href=\"(.*?)index.php/,'href="' + wiki_url[0].to_s + 'index.php')
  end
 ##
  # review_mediawiki
  #
  # author: Jeffrey T. Haug
  #
  # usage: To be used in a view such as:
  #
  # <%= review_mediawiki 'http://pg-server.ece.ncsu.edu/mediawiki/index.php/ECE633:hw1', '2007/06/11', 'jthaug'  %>
  #
  # @args: _assignment_url (URL of the wiki assignment.)
  # @args: _start_date (all review items older will be filtered out)
  # @args: _wiki_user (wiki user id to crawl)
  ##
  # @param _assignment_url [Object]
  # @param _assignment_id [Object]
  # @param _wiki_user [Object]
  def self.review_mediawiki_new(_assignment_url, _assignment_id, _wiki_user = nil)

    response = '' #the response from the URL
    #Check to make sure we were passed a valid URL
    matches = /http:/.match( _assignment_url )
    if not matches or _assignment_id.nil?
      return response
    end

    current_assignment = Assignment.find(_assignment_id)
    start_date =  current_assignment.created_at
    due_dates = DueDate.find(:all, :conditions => ["assignment_id = ?",_assignment_id],:order => "due_at DESC")
    end_date = due_dates[0]

    #Args
    url = _assignment_url.chomp("/")
    wiki_url = _assignment_url.scan(/(.*?)index.php/)
    namespace = _assignment_url.split(/\//)
    namespace_url = namespace.last
    _wiki_user.gsub!(" ","+")

    #Media Wiki Specific
    review = "index.php?limit=1000&tagFilter=&title=Special%3AContributions&contribs=user&target=" + _wiki_user+"&namespace=&year=&month=-1"
    #Grab this user's contributions
    url = wiki_url[0].to_s + review
    @urlin = url


    response = getwikipage(url)

    #Clean URLs
    response = cleanURLS(response,wiki_url)
    contribution_list = response.scan(/<li class=""><a href=".*?<\/li>/)
    line_items = response.scan(/<li class=""><a href=".*?>/)

    @res = response
    # if the user has no assignments submitted
    is_link_present = response.scan(/No changes were found matching these criteria/)
    if(is_link_present[0].nil? == false)
      return ''
    end

    #Extract the dates only
    dates = Array.new
    contribution_list.each do |contribution|
      scanned_date = contribution.scan(/\d\d:\d\d, \d+ \w+ \d\d\d\d/)
      dates << Time.parse(scanned_date[0])
    end

    # for each of the dates check if the date is within the assigment deadlines.
    condition = lambda{|date| start_date > date}
    compareDates(condition,dates,line_items)
    condition = lambda{|date| end_date.due_at < date}
    compareDates(condition,dates,line_items)

    line_items.compact!
    # check for the line_items being empty
    if !(line_items.empty?)
      latest_title = line_items[0].scan(/".*?"/)
      latest_title[2] = latest_title[2].gsub(/"/,'')
      latest_url = line_items[0].gsub(/&amp.*?"/,'"') + latest_title[2] +'</a></li>'
      return latest_url
    end
    return ''
  end
end
