class BookmarksController < ApplicationController

  ## search for bookmarks - specifying comma separated tags
 def search_bookmarks
      ## add all the java script validations later on
      ## seaches for all bookmarks tagged with the values passed on the search string
        @search_string = params[:s]
        @my_user_temp = params[:users]
        puts @my_user_temp
        @order_by = params[:order_by]
        if params[:order_by] == nil
            @order_by = "most_recent"
        else
            @order_by = params[:order_by].to_s
        end
        #when getting the hidden variable from the form for the users to include.. you might get "value" appended to the string before the param that you
        ##expect .. Remove that
        @my_user = @my_user_temp.gsub(/value/,'');

        @search_array  = BookmarksHelper.separate_tags( @search_string)
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



    ## View bookmarks and search bookmarks of all the user
  def view_bookmarks
       @topic_name = ""
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

       @search_results  = nil

       @users_included ="All Included users"
       if params[:id] == nil
          @method_name = "view_bookmarks"
          @search_results = Bookmark.search_alltags_allusers(@order_by)
       else
          @method_name = "view_bookmarks_by_topic"
          @search_results = Bookmark.search_bookmarks_by_topic_id(params[:id],@order_by)
          @topic_name = SignUpTopic.find(params[:id]).topic_name
       end
    
       #Call the model function with order by parameter
   end

  def add
	## if added properly should be redirected to the users collection of bookmarks. if not. should render the form again
    ## get all the required data from the form
    ## b_url b_type, b_title b_tags_text, b_type b_description
    b_url =  params[:b_url]
    ### need validations for b_url - make it into a 
    b_title = params[:b_title]
    b_tags_text = params[:b_tags_text]
    b_description = params[:b_description]
    prepare_string(b_url)
    topic_id = params[:b_topicid]
    session_user = session[:user]
    Bookmark.add_this_bookmark(topic_id,b_url, b_title, b_tags_text, b_description,session_user)
    
    redirect_to :action => 'manage_bookmarks'
  end

  def new
	  #redirects to /Bookmarks/new.html.erb
  end

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
       @result_tuple["tags"]  = BookmarksHelper.join_tags(tag_array)
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

  def prepare_string(mystring)
    # for a given string remove all spaces to the left, right, and downcase all of it - sepcifically done to urls, and search tags
     b_tag1 = mystring.lstrip
     b_tag2 = b_tag1.rstrip
     b_tag3 = b_tag2.downcase
    return b_tag3
   end
   

def copy
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
           @b_tags_text  = BookmarksHelper.join_tags(tag_array)
          @b_description = @bookmark_mapping.description
end

## copy a bokmark from some one else's repository.
    def copybookmark
      b_url =  params[:b_url]
      b_title = params[:b_title]
      b_tags_text = params[:b_tags_text]
      b_description = params[:b_description]
      session_user = session[:user]
      Bookmark.add_this_bookmark(-1,b_url, b_title, b_tags_text, b_description,session_user)
      redirect_to :action => 'manage_bookmarks'
    end
    
    
def edit
          @bookmark_mapping_id = params[:id]
          @bookmark_mapping =  Bmapping.find(params[:id])
          @edit_tuple = Hash.new
          @edit_tuple["b_url"] = @bookmark_mapping.bookmark.url
          @edit_tuple["b_id"] = @bookmark_mapping.id
          @edit_tuple["b_title"] =  @bookmark_mapping.title
          @edit_tuple["b_tags_text"] = ""
          tag_fetchs = Qualifier.find(:all, :conditions=>["bmapping_id = ?",@bookmark_mapping.id])
          tag_array = Array.new
          for tag_fetch in tag_fetchs
             tag_array <<  Tag.find(tag_fetch.tag_id).tagname
          end
          @edit_tuple["b_tags_text"]  = BookmarksHelper.join_tags(tag_array)
          @edit_tuple["b_description"] = @bookmark_mapping.description          
          
 end


    def editbookmark
          ### difference between edit and add - new = add new adds tuple if it downt find any, edit tuple modifies only if it finds something
            b_url =  params["b_url"]
            b_title = params["b_title"]
            b_tags_text = params["b_tags_text"]
            b_description = params["b_description"]
            session_user = session[:user]
            Bookmark.edit_this_bookmark(b_url, b_title, b_tags_text, b_description, session_user)
            redirect_to :action => 'manage_bookmarks'

    end
    
end



