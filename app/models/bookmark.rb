class Bookmark < ActiveRecord::Base
	has_many :bmappings

##SEARCH FUNCTIONS

  ## gives the 20 most popular or 20 most recent bookmarks in the system, depending on the order_by parameter. Function returns
  ## an array. Each element of the array is a hash, detailing one record
    def self.search_alltags_allusers(order_by)
      result_array = Array.new        #going to append all the results into this array


      if(order_by == "most_recent")
        ## find all the records in the system, order them by the date created. Using Bmapping here. Returns mappings that where created most recently,
        ## the user that created this mapping, the title and description provided  this user
        result_records = Bmapping.find(:all, :order =>"date_created DESC", :limit =>20)

        for result in result_records
          ## for each tuple returned by the query above, create a new hash, store the values appropriately, and append into the return_array
          result_hash = Hash.new
          result_hash["id"] = result.id
          result_hash["url"] = result.bookmark.url
          result_hash["user"] = result.user.name    # displaying the newest owner of the bookmark,
          result_hash["title"] = result.title
          result_hash["created_at"] = result.date_created
          result_hash["description"] = result.description
          result_hash["copied_by"] = result.bookmark.user_count     ## number of people having this user in their repository
          ## now retrieving tags for this user-bookmak mapping
          ## first retrieve all the tag_ids mapped to the BMapping id. Then retrieve all the tag names of the tag_ids picked up.
          ## Append all these into a comma separated string, and push them onto the hash
          tag_fetchs = Qualifier.find(:all, :conditions=>["bmapping_id = ?",result.id])
          tag_array = Array.new
          for tag_fetch in tag_fetchs
             tag_array <<  Tag.find(tag_fetch.tag_id).tagname
          end
          result_hash["tags"]  = BookmarksHelper.join_tags(tag_array)
          result_array << result_hash

        end
      elsif (order_by == "most_popular")
        ## returns the url boomarked by the most number of users, the discoverer of that url, the title and description provided by the discoverer
       result_records = Bookmark.find(:all, :order =>"user_count DESC", :limit =>20)
        for result in result_records
          ## for each tuple returned by the query above, create a new hash, store the values appropriately, and append into the return_array
          result_hash = Hash.new
          result_hash["url"] = result.url
          result_hash["user"] =  User.find(result.discoverer_user_id).name
          result_hash["copied_by"] =  result.user_count
          b_u_mapping = Bmapping.find(:first, :conditions =>["bookmark_id = ? and user_id = ?", result.id, result.discoverer_user_id])
          result_hash["id"] = b_u_mapping.id
          result_hash["description"]  = b_u_mapping.description
          result_hash["title"] =  b_u_mapping.title
          ## now retrieving tags for this user-bookmak mapping
          ## first retrieve all the tag_ids mapped to the BMapping id. Then retrieve all the tag names of the tag_ids picked up.
          ## Append all these into a comma separated string, and push them onto the hash

          tag_fetchs =  Qualifier.find(:all, :conditions=>["bmapping_id = ?",b_u_mapping.id])
          tag_array = Array.new
          for tag_fetch in tag_fetchs
            tag_array <<  Tag.find(tag_fetch.tag_id).tagname
          end
          result_hash["tags"]  = BookmarksHelper.join_tags(tag_array)
          result_array << result_hash
        end
      end
     return result_array

    end

  ######

  
def self.search_bookmarks_by_topic_id(topic_id,order_by)
      result_array = Array.new        #going to append all the results into this array


      if(order_by == "most_recent")
        ## find all the records in the system, order them by the date created. Using Bmapping here. Returns mappings that where created most recently,
        ## the user that created this mapping, the title and description provided  this user
        result_records = Bmapping.find(:all, :conditions =>["sign_up_topic_id = ?", topic_id] , :order =>"date_created DESC", :limit =>20)

        for result in result_records
          ## for each tuple returned by the query above, create a new hash, store the values appropriately, and append into the return_array
          result_hash = Hash.new
          result_hash["id"] = result.id
          result_hash["url"] = result.bookmark.url
          result_hash["user"] = result.user.name    # displaying the newest owner of the bookmark,
          result_hash["title"] = result.title
          result_hash["created_at"] = result.date_created
          result_hash["description"] = result.description
          result_hash["copied_by"] = result.bookmark.user_count     ## number of people having this user in their repository
          ## now retrieving tags for this user-bookmak mapping
          ## first retrieve all the tag_ids mapped to the BMapping id. Then retrieve all the tag names of the tag_ids picked up.
          ## Append all these into a comma separated string, and push them onto the hash
          tag_fetchs = Qualifier.find(:all, :conditions=>["bmapping_id = ?",result.id])
          tag_array = Array.new
          for tag_fetch in tag_fetchs
             tag_array <<  Tag.find(tag_fetch.tag_id).tagname
          end
          result_hash["tags"]  = BookmarksHelper.join_tags(tag_array)
          result_array << result_hash

        end
      elsif (order_by == "most_popular")
        ## returns the url boomarked by the most number of users, the discoverer of that url, the title and description provided by the discoverer
       result_records = Bookmark.find(:all, :order =>"user_count DESC", :limit =>20)

        for result in result_records
          ## for each tuple returned by the query above, create a new hash, store the values appropriately, and append into the return_array
          result_hash = Hash.new
          result_hash["url"] = result.url
          result_hash["user"] =  User.find(result.discoverer_user_id).name
          result_hash["copied_by"] =  result.user_count
          b_u_mapping = Bmapping.find(:first, :conditions =>["bookmark_id = ? and user_id = ?", result.id, result.discoverer_user_id])
          result_hash["id"] = b_u_mapping.id
          
          result_hash["description"]  = b_u_mapping.description
          result_hash["title"] =  b_u_mapping.title
          ## now retrieving tags for this user-bookmak mapping
          ## first retrieve all the tag_ids mapped to the BMapping id. Then retrieve all the tag names of the tag_ids picked up.
          ## Append all these into a comma separated string, and push them onto the hash

          tag_fetchs =  Qualifier.find(:all, :conditions=>["bmapping_id = ?",b_u_mapping.id])
          tag_array = Array.new
          for tag_fetch in tag_fetchs
            tag_array <<  Tag.find(tag_fetch.tag_id).tagname
          end
          result_hash["tags"]  = BookmarksHelper.join_tags(tag_array)
          result_array << result_hash

        end
      end
     return result_array

    end


  ## returns the 20 most recent bookmarks_mappings made by the user specified, or the most popular bookmarks in this user's repository, depending on the order_by
 ## Function returns an array. Each element of the array is a hash detailing one record
    def self.search_alltags_foruser  (the_userid, order_by)
       result_array = Array.new        #going to append all the results into this array


       if(order_by == "most_recent" )
         ## find all the bmappings in this system, created by this user, order them by the date created.
         # For each tuple returned from the bmapping, generate a hash, containing the url, the specified user's name, date this mapping was made,
         ## title, and description provided by this user. Store these hashes sequentially in a array ad return the array

        result_records = Bmapping.find(:all, :conditions=>[" user_id = ?", the_userid], :order =>"date_created DESC", :limit => 20)
        for result in result_records
         result_hash = Hash.new
         result_hash["id"] = result.id
         result_hash["url"] = result.bookmark.url
         result_hash["user"] = User.find(the_userid).name
         result_hash["created_at"] = result.date_created
         result_hash["title"] = result.title
         result_hash["description"] = result.description
         result_hash["copied_by"] = result.bookmark.user_count
         ## now retrieving tags for this user-bookmak mapping
         ## first retrieve all the tag_ids mapped to the BMapping id. Then retrieve all the tag names of the tag_ids picked up.
         ## Append all these into a comma separated string, and push them onto the hash

         tag_fetchs = Qualifier.find(:all, :conditions =>["bmapping_id = ?",result.id])
         tag_array = Array.new
         for tag_fetch in tag_fetchs
         tag_array <<  Tag.find(tag_fetch.tag_id).tagname
         end
           result_hash["tags"]  = BookmarksHelper.join_tags(tag_array)
           result_array << result_hash
        end
       elsif ( order_by == "most_popular")
          ### retrieving the most popular records that this user.(The user need not be the discoverer). First retrieve the the user's bookmarks from the bmapping.
         ### order these records, based on the user_count of the url
          temp_result_records = Bmapping.find(:all, :conditions=>[" user_id = ?", the_userid])
          ## order result records by result.user_count  a.sort {|x,y| y <=> x }
            result_records = temp_result_records.sort {|x,y| y.bookmark.user_count <=> x.bookmark.user_count}
            for result in result_records
              result_hash = Hash.new
              result_hash["url"] = result.bookmark.url
              result_hash["id"] = result.id
              result_hash["user"] =  User.find(the_userid).name
              result_hash["title"] = result.title
              result_hash["description"] = result.description
              result_hash["copied_by"] = result.bookmark.user_count
              ## now retrieving tags for this user-bookmak mapping
              ## first retrieve all the tag_ids mapped to the BMapping id. Then retrieve all the tag names of the tag_ids picked up.
              ## Append all these into a comma separated string, and push them onto the hash

              tag_fetchs = Qualifier.find(:all, :conditions =>["bmapping_id = ?",result.id])
              tag_array = Array.new
              for tag_fetch in tag_fetchs
                 tag_array <<  Tag.find(tag_fetch.tag_id).tagname
              end
              result_hash["tags"]  =BookmarksHelper.join_tags(tag_array)
              result_array << result_hash
            end

       end

     return result_array
   end

  ## Searches the system for bookmarks that were tagged with all the "words" passed in the tags_array. Orders these results based on the order_by pattern
   def  self.search_fortags_allusers(tags_array, order_by)

      result_array = Array.new # returns this array
      ## find the tags associated with these tagnames
      @tags = BookmarksHelper.find_tags(tags_array)
      @q_tuples_with_all_tags = Array.new
      ## retreive mapping_ids taggeed with all of the word tags
      ## for every word, search for every bookmark that was tagged with that word. Then take the intersection of all the bmapping_ids
      first_time = "true"
      for each_tag in @tags
         puts "for tag name -> #{each_tag.tagname}"

          q_tuples = Qualifier.find(:all, :conditions =>["tag_id = ?", each_tag])

          if first_time == "true"
             puts "first time = #{first_time}"
             for q_t in q_tuples
                  @q_tuples_with_all_tags << q_t.bmapping_id
             end

             first_time = "false"
           else
             puts "first time = #{first_time}"
             temp_array = Array.new
             for q_t in q_tuples
               temp_array << q_t.bmapping_id
             end
             #@q_tuples_with_all_tags = @q_tuples_with_all_tags & temp_array ## returns the items  common to both arrays
            end

     end
     ## now you have qualifer tuples with all the required bmapping ids - search for the req ones
      temp_result_records =  Bmapping.find(:all, :conditions =>["id in (?)", @q_tuples_with_all_tags])
      result_records = Array.new
      ## organize these tuples in the order of most earliest, most popular
        if (order_by =="most_recent")
          result_records = temp_result_records.sort {|x,y| y.date_created <=> x.date_created}
        else
          result_records = temp_result_records.sort {|x,y| y.bookmark.user_count <=> x.bookmark.user_count }
        end
      ## for evey bmapping_id, create a hash, and push into the result_array
      for result in result_records
         result_hash = Hash.new
         result_hash["id"] = result.id
         result_hash["url"] = result.bookmark.url
         result_hash["created_at"] = result.date_created
         result_hash["user"] = result.user.name
         result_hash["title"] = result.title
         result_hash["description"] = result.description
         result_hash["copied_by"] = result.bookmark.user_count
         ## now retrieving tags for this user-bookmak mapping
         ## first retrieve all the tag_ids mapped to the BMapping id. Then retrieve all the tag names of the tag_ids picked up.
         ## Append all these into a comma separated string, and push them onto the hash

         tag_fetchs = Qualifier.find(:all,:conditions=>["bmapping_id =?",result.id])
         tag_array = Array.new
         for tag_fetch in tag_fetchs
         tag_array <<  Tag.find(tag_fetch.tag_id).tagname
         end
           result_hash["tags"]  = BookmarksHelper.join_tags(tag_array)
           result_array << result_hash
        end
     return result_array
   end
## searches for tspecified tags, among a specified user, orders them by most popular and the most recently added
   def self.search_fortags_foruser(tags_array, this_user_id, order_by)
     #order by is in "most_popular" and "most_recent"
     result_array = Array.new


     ## search for ids of the tags
      @tags = BookmarksHelper.find_tags(tags_array)
      @b_mappings_id_array = Array.new
      for each_tag in @tags
       puts "for tag name -> #{each_tag.tagname}"
     ##search for all qualifier tuples with b
       q_tuples = Qualifier.find(:all, :conditions =>["tag_id = ?", each_tag])
           puts "printing out q_tuples"
       for q_t in q_tuples
         puts q_t.bmapping_id
		@b_mappings_id_array <<	q_t.bmapping_id
       end
	end

     ## now you have qualifer tuples with all the required bmapping ids - search for the req ones
     temp_result_records =  Bmapping.find(:all, :conditions =>["id in (?) and user_id = ?", @b_mappings_id_array,this_user_id ])
      ## organize these tuples in the order of most earliest, most popular
     result_records = Array.new
     if (order_by == "most_recent")
        result_records = temp_result_records.sort {|x,y| y.date_created <=> x.date_created}
     else
        result_records = temp_result_records.sort {|x,y| y.bookmark.user_count <=> x.bookmark.user_count }
     end
     for result in result_records
        result_hash = Hash.new
        result_hash["id"] = result.id
        result_hash["url"] = result.bookmark.url
        result_hash["user"] =  User.find(this_user_id).name
        result_hash["title"] = result.title
        result_hash["description"] = result.description
        result_hash["copied_by"] = result.bookmark.user_count
        result_hash["created_at"] = result.date_created
        ## now retrieving tags for this user-bookmak mapping
        ## first retrieve all the tag_ids mapped to the BMapping id. Then retrieve all the tag names of the tag_ids picked up.
        ## Append all these into a comma separated string, and push them onto the hash

        tag_fetchs = Qualifier.find(:all, :conditions=>["bmapping_id=?",result.id])
        tag_array = Array.new
        for tag_fetch in tag_fetchs
           tag_array <<  Tag.find(tag_fetch.tag_id).tagname
        end
        result_hash["tags"]  = BookmarksHelper.join_tags(tag_array)
        result_array << result_hash
     end
     return result_array
   end

    ## ADDING BOOKMARK/EDITING BOOKMARK FUNCTION


  ## check if bookmark url exists. If the url does exists, check if the user has this bookmark in his repository
  def self.check_bookmark_and_mapping (b_url, session_user)
   bookmark_resource = Bookmark.find(:first, :conditions=>["url = ?",b_url])
   return_string = ""
    if bookmark_resource == nil
        return_string = "url_not_found"
    else
        bookmark_user_mapping = Bmapping.find(:first, :conditions =>["user_id = ? and bookmark_id = ?", session_user.id, bookmark_resource.id])
         if( bookmark_user_mapping == nil)
            return_string = "mapping_not_found"
         else
             return_string = "mapping_exists"
         end
    end

    return return_string
  end
     ## if bookmark mapping for a user and a url exists, then edit
    def self.edit_this_bookmark (b_url, b_title, b_tags_text, b_description,session_user)
     bookmark_resource = Bookmark.find(:first, :conditions=>["url = ?",b_url])
     bmapping_status = "found"
     bookmark_user_mapping = Bmapping.find(:first, :conditions =>["user_id = ? and bookmark_id = ?", session_user.id, bookmark_resource.id])
     bookmark_user_mapping.bookmark_id = bookmark_resource.id
     bookmark_user_mapping.title = b_title
     bookmark_user_mapping.description = b_description
     bookmark_user_mapping.user_id = session_user.id
     current_timestamp = Time.now
     bookmark_user_mapping.date_modified = current_timestamp
     bookmark_user_mapping.save


               ## deleting existing tags
     Qualifier.destroy_all(["bmapping_id = ?", bookmark_user_mapping.id])
        puts "!!@@@@###$$$ looking at tags"
        tag_array =  BookmarksHelper.separate_tags(b_tags_text)
        for each_tag in tag_array
             puts each_tag
                ## look for each tag that is present in tags, if not make them, then make the qualifier entry
             tag_tuple = Tag.find(:first, :conditions=>["tagname = ?",each_tag])
             if(tag_tuple == nil )
                  puts "NEW TAG #{each_tag}"
                  tag_tuple = Tag.new
                  tag_tuple.tagname = each_tag
                  tag_tuple.save
             end
                ## the entries in the qualifier have been deleted.. so all tags are associated freshly now


             puts "btu_tuple - qualifier is nil for tag #{each_tag} - tag - tuple id #{tag_tuple.id} n bmapping_id #{bookmark_user_mapping.id} "
                  btu_tuple = Qualifier.new
                  btu_tuple.tag_id = tag_tuple.id
                  btu_tuple.bmapping_id = bookmark_user_mapping.id
                  btu_tuple.save
        end
     end


## add bookmark and bmapping. Check if url exists bmapping exists, if it does - edits, if it doesnt - adds
  def self.add_this_bookmark(topic_id,b_url, b_title, b_tags_text, b_description,session_user)
    status_string = Bookmark.check_bookmark_and_mapping(b_url,session_user)
      if(status_string == "url_not_found"|| status_string == "mapping_not_found")
             Bookmark.adding_bookmark(topic_id,b_url, b_title, b_tags_text, b_description,session_user)
      elsif(status_string == "mapping_exists")
             Bookmark.edit_this_bookmark(b_url, b_title, b_tags_text, b_description,session_user)

      end

  end


  ##adds url if it doesn't exist, adds the appropriate bmapping
   def self.adding_bookmark(topic_id, b_url, b_title, b_tags_text, b_description,session_user)
      bookmark_resource = Bookmark.find(:first, :conditions =>["url = ?",b_url])
      if (bookmark_resource == nil)
               ## create a resource
         bookmark_resource = Bookmark.new
         bookmark_resource.url = b_url
         bookmark_resource.discoverer_user_id = session_user.id
         bookmark_resource.user_count = 0
         bookmark_resource.save
      end

           ##check whether the bookmark_user mapping is present
      bookmark_user_mapping = Bmapping.new
      bookmark_user_mapping.bookmark_id   = bookmark_resource.id
      bookmark_user_mapping.title = b_title
      bookmark_user_mapping.description = b_description
      bookmark_user_mapping.user_id = session_user.id
      current_timestamp = Time.now
      bookmark_user_mapping.date_created = current_timestamp
      bookmark_user_mapping.date_modified = current_timestamp
      bookmark_user_mapping.sign_up_topic_id = topic_id
      bookmark_user_mapping.save
      bookmark_resource.user_count = bookmark_resource.user_count+1
      bookmark_resource.save

             ## tags come in as a text, separating them into a array
      tag_array = BookmarksHelper.separate_tags(b_tags_text)
      for each_tag in tag_array
         puts "TAGNAME ="
         puts each_tag
               ## look for each tag that is present in tags, if not make them, then make the BTU entry
         tag_tuple = Tag.find(:first, :conditions =>["tagname = ?",each_tag])
         if(tag_tuple == nil )
                 puts "WE JUST FOUND OUT THAT TAGNAME DOeS NOT EXISTS in tag repo"
                 tag_tuple = Tag.new
                 tag_tuple.tagname = each_tag
                 tag_tuple.save
         end
               ## check if there is an entry for this tag , this user and this bookmar
         puts "now checking qualifier - args first, tag_id, bmapping_id"
         puts tag_tuple.id
         puts bookmark_user_mapping.id
         btu_tuple =  Qualifier.find(:first, :conditions =>[ "tag_id = ? and bmapping_id = ?", tag_tuple.id, bookmark_user_mapping.id] )
         if btu_tuple == nil
                 puts "$$$$$$$$$$ btu_tuple is nil"
                 btu_tuple = Qualifier.new
                 btu_tuple.tag_id = tag_tuple.id
                 btu_tuple.bmapping_id = bookmark_user_mapping.id
                 btu_tuple.save
         end

      end     
 end


  end
