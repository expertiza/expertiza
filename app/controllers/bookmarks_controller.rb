class BookmarksController < ApplicationController

      ## View bookmarks and search bookmarks of all the user
    def view_bookmarks
         @search_content = ""
        @order_by = ""
        if params[:s] != nil
         @search_content = params[:s]
    end
        ## viewing all the bookmarks that are present!
        if params[:order_by] == nil
            @order_by = "most_recent"
        else
            @order_by = params[:order_by].to_s
        end
        @users_included ="All Included users"
        @method_name = "view_bookmarks"
        #Call the model function with ordrer by parameter
        @search_results = Bookmark.search_alltags_allusers(@order_by)

    end
    
    

     ## manage and search your own bookmarks
    def manage_bookmarks
      @my_user_id = session[:user].id
      @search_content = ""
      @order_by = ""
      if params[:s] != nil
          @search_content = params[:s]
      end

      if params[:order_by] == nil
          @order_by = "most_recent"
      else
          @order_by = params[:order_by].to_s
      end
      @users_included ="All Included users"
      @method_name = "manage_bookmarks"
      #Call the model function with ordrer by parameter
      @search_results = Bookmark.search_alltags_foruser(@my_user_id, @order_by)

    end


 def separate_tags( my_tag_string)
    my_return_array = Array.new
    temp_tags = my_tag_string.split(/,/)
    for b_tag in temp_tags
      b_tag1 = b_tag.lstrip
      b_tag2 = b_tag1.rstrip
      b_tag3 = b_tag2.downcase
      if b_tag3 != nil && !(b_tag3.empty?)
        my_return_array << b_tag3
      end
    end
    return my_return_array
  end



## search for bookmarks - specifying comma separated tags
    def search_bookmarks
      ## add all the java script validations later on
      ## seaches for all bookmarks tagged with the values passed on the search string
        @search_string = params[:s]
        @my_user_temp = params[:users]
        @order_by = params[:order_by]
        if params[:order_by] == nil
            @order_by = "most_recent"
        else
            @order_by = params[:order_by].to_s
        end
        #when getting the hidden variable from the form for the users to include.. you might get "value" appended to the string before the param that you
        ##expect .. Remove that
        @my_user = @my_user_temp.gsub (/value/, '');

        @search_array  = separate_tags( @search_string)
        @method_name = "search_bookmarks"


        @search_results = Array.new
        if (@my_user != 'all_users')
          @search_results = Bookmark.search_fortags_foruser(@search_array, @my_user, @order_by)
        else
           @search_results = Bookmark.search_fortags_allusers(@search_array, @order_by)
        end
        if(@my_user == "all_users")
           render :action => "view_bookmarks"
        else
           render :action =>"manage_bookmarks"
        end           
    end
    
    def add_bookmark_form
       ## b_url b_type, b_title b_tags_text, b_type b_description
          @b_url = ""
          @b_title = ""
          @b_tags_text = ""
          @b_description = ""
    
          @topic_id=params[:id]
          return @topic_id
          
    end
  


    ### functions for crud of bookmarks
    def add_bookmark
      ## if added properly should be redirected to the users collection of bookmarks. if not. should render the form again
      ## get all the required data from the form
      ## b_url b_type, b_title b_tags_text, b_type b_description
      b_url =  params[:b_url]
      ### need validations for b_url - make it into a 
      b_title = params[:b_title]
      b_tags_text = params[:b_tags_text]
      b_description = params[:b_description]
      prepare_string(b_url)
      session_user = session[:user]
      
      @topicid=params[:topicid]            
      if @topicid !=nil 
            Bookmark.add_topic_bookmark(b_url, b_title, b_tags_text, b_description,session_user,@topicid)      
    		params[:id]=@topicid
    		redirect_to :action => 'view_topic_bookmarks', :id => @topicid
      else
		  Bookmark.add_this_bookmark(b_url, b_title, b_tags_text, b_description,session_user)
		  redirect_to :action => 'manage_bookmarks'
      end

     
    end
    
    
 	 def edit_bookmark_form
      @bookmark_mapping = Bmapping.find(params[:id])

          @b_id =   @bookmark_mapping.id
          @b_url = @bookmark_mapping.bookmark.url
          @b_title =  @bookmark_mapping.title
          @b_tags_text = ""
          tag_fetchs = Qualifier.find(:all, :conditions=>["bmapping_id = ?",@bookmark_mapping.id])
          tag_array = Array.new
          for tag_fetch in tag_fetchs
             tag_array <<  Tag.find(tag_fetch.tag_id).tagname
          end
           @b_tags_text  = join_tags(tag_array)
          @b_description = @bookmark_mapping.description
    end


    def edit_bookmark

      ### difference between edit and add - new = add new adds tuple if it downt find any, edit tuple modifies only if it finds something
            b_url =  params["b_url"]
            b_title = params["b_title"]
            b_tags_text = params["b_tags_text"]
            b_description = params["b_description"]
            session_user = session[:user]
            Bookmark.edit_this_bookmark(b_url, b_title, b_tags_text, b_description, session_user)

            redirect_to :action => 'manage_bookmarks'

    end


    def copy_bookmark_form
          puts params[:id]
          @bookmark_mapping = Bmapping.find(params[:id])
          @b_id =   @bookmark_mapping.id
          @b_url = @bookmark_mapping.bookmark.url
          @b_title =  @bookmark_mapping.title
          @b_tags_text = ""
          tag_fetchs = Qualifier.find(:all, :conditions=>["bmapping_id =?",@bookmark_mapping.id])
          tag_array = Array.new
          for tag_fetch in tag_fetchs
             tag_array <<  Tag.find(tag_fetch.tag_id).tagname
          end
           @b_tags_text  = join_tags(tag_array)
          @b_description = @bookmark_mapping.description

    end
  ## copy a bokmark from some one else's repository.
    def copy_bookmark

      b_url =  params[:b_url]
      b_title = params[:b_title]
      b_tags_text = params[:b_tags_text]
      b_description = params[:b_description]
      session_user = session[:user]
      Bookmark.add_this_bookmark(b_url, b_title, b_tags_text, b_description,session_user)

      redirect_to :action => 'manage_bookmarks'
       end
 
    def delete_bookmark

    end
    
 ## viewing a particualr bookmark
    def view
      @bookmark_mapping_id = params[:id]
      @bookmark_mapping =  Bmapping.find(params[:id])
      @result_tuple = Hash.new
      @result_tuple["bmapping_id"] = @bookmark_mapping.id
      @result_tuple["bookmark_id"] = @bookmark_mapping.bookmark_id
      @result_tuple["owner"] = @bookmark_mapping.user.name
      @result_tuple["title"] = @bookmark_mapping.title
      @result_tuple["discoverer"] = User.find(@bookmark_mapping.bookmark.discoverer_user_id).name
      @result_tuple["description"] = @bookmark_mapping.description
      @result_tuple["url"] = @bookmark_mapping.bookmark.url
      @result_tuple["user_count"]  = @bookmark_mapping.bookmark.user_count
      tag_fetchs = Qualifier.find(:all, :conditions =>["bmapping_id = ?",@bookmark_mapping.id])
      tag_array = Array.new
      for tag_fetch in tag_fetchs
          tag_array <<  Tag.find(tag_fetch.tag_id).tagname
      end
      @result_tuple["tags"]  = join_tags(tag_array)
    end

  def self.find_tags(tags_array )
     @tags = Array.new
    for each_of_my_tag in tags_array
      this_tag_tuple= Tag.find(:first, :conditions=>["tagname = ?",each_of_my_tag])
      if this_tag_tuple != nil
        puts " We found one matching"
        @tags << this_tag_tuple
      else
        puts " We dint find any matching for #{each_of_my_tag}"
      end
    end
         return @tags
  end

  def join_tags(my_tag_array)
 my_return_string = ""
  for each_tag in my_tag_array
    my_return_string = my_return_string +each_tag + ", "
  end
    return my_return_string
  end

  def separate_tags( my_tag_string)
    my_return_array = Array.new
    temp_tags = my_tag_string.split(/,/)
    for b_tag in temp_tags
      b_tag1 = b_tag.lstrip
      b_tag2 = b_tag1.rstrip
      b_tag3 = b_tag2.downcase
      if b_tag3 != nil && !(b_tag3.empty?)
        my_return_array << b_tag3
      end
    end
    return my_return_array
  end

  def prepare_string(mystring)
    # for a given string remove all spaces to the left, right, and downcase all of it - sepcifically done to urls, and search tags

     b_tag1 = mystring.lstrip
     b_tag2 = b_tag1.rstrip
     b_tag3 = b_tag2.downcase
    return b_tag3
   end
   
   
  def view_topic_bookmarks
  
  	@assignment_id=params[:assignment_id]	
  	@topic = SignUpTopic.find(params[:id]) 
  	   
    @search_results = Array.new
    if @topic 
    	for bmapping in @topic.bmappings
    		result_hash = Hash.new
	        result_hash["id"] = bmapping.id
	        result_hash["url"] = bmapping.bookmark.url
	        result_hash["user"] =  bmapping.user.name
	        result_hash["title"] = bmapping.title
	        result_hash["description"] = bmapping.description
	        result_hash["copied_by"] = bmapping.bookmark.user_count
	        result_hash["created_at"] = bmapping.date_created
	        ## now retrieving tags for this user-bookmak mapping
	        ## first retrieve all the tag_ids mapped to the BMapping id. Then retrieve all the tag names of the tag_ids picked up.
	        ## Append all these into a comma separated string, and push them onto the hash
	
	        tag_fetchs = Qualifier.find(:all, :conditions=>["bmapping_id=?",bmapping.id])
	        tag_array = Array.new
	        for tag_fetch in tag_fetchs
	           tag_array <<  Tag.find(tag_fetch.tag_id).tagname
	        end
	        result_hash["tags"]  = BookmarksHelper.join_tags(tag_array)
	        result_hash["bookmark"] = bmapping.bookmark
	        @search_results << result_hash    	
	    end
    end
  end   
end
