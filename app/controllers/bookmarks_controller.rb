class BookmarksController < ApplicationController
  def add_bookmark_form
    # Fields: b_url b_type, b_title b_tags_text, b_type b_description
    @b_url = ""
    @b_title = ""
    @b_tags_text = ""
    @b_description = ""
    @topic_id = params[:id]
    return @topic_id
  end

  def add_bookmark
    # If added properly should be redirected to the users collection of bookmarks.
    # If not, should render the form again
    # Get all the required data from the form
    # b_url b_type, b_title b_tags_text, b_type b_description
    b_url = params[:b_url]
    b_title = params[:b_title]
    b_tags_text = params[:b_tags_text]
    b_description = params[:b_description]
    BookmarksHelper.prepare_string(b_url)
    session_user = session[:user]
    @topicid = params[:topicid]
    if @topicid
    # Add the topic bookmark
    Bookmark.add_topic_bookmark(b_url, b_title, b_tags_text, b_description,session_user, @topicid)
    params[:id] = @topicid
    redirect_to(:action => 'view_topic_bookmarks', :id => @topicid)
    else
    Bookmark.add_this_bookmark(b_url, b_title, b_tags_text, b_description,session_user)
    redirect_to(:action => 'manage_bookmarks')
    end
  end

  # Manage and search your own bookmarks
  def manage_bookmarks
    @my_user_id = session[:user].id
    @search_content = ""
    @order_by = ""
    unless params[:s].nil?
    @search_content = params[:s]
    end
    if params[:order_by].nil?
    @order_by = "most_recent"
    else
    @order_by = params[:order_by].to_s
    end
    @users_included ="All Included users"
    @method_name = "manage_bookmarks"
    # Call the model function with ordrer by parameter
    @search_results = Bookmark.search_alltags_foruser(@my_user_id, @order_by)
  end

  #Listing all the bookmarks for a topic
  def view_topic_bookmarks
    @assignment_id=params[:assignment_id]
    @topic = SignUpTopic.find(params[:id])
    @search_results = Array.new
    if @topic
      for bmapping in @topic.bmappings
        result_hash = Hash.new
        result_hash["id"] = bmapping.id
        result_hash["url"] = bmapping.bookmark.url
        result_hash["user"] = bmapping.user.name
        result_hash["title"] = bmapping.title
        result_hash["description"] = bmapping.description
        result_hash["copied_by"] = bmapping.bookmark.user_count
        result_hash["created_at"] = bmapping.date_created
        # Now retrieving tags for this user-bookmark mapping
        # First retrieve all the tag_ids mapped to the BMapping id.
        # Then retrieve all the tag names of the tag_ids picked up.
        # Append all these into a comma separated string, and push them onto the hash
        tag_fetchs = BmappingsTags.find(:all, :conditions=>["bmapping_id=?",bmapping.id])
        tag_array = Array.new
        for tag_fetch in tag_fetchs
          tag_array << Tag.find(tag_fetch.tag_id).tagname
        end
        result_hash["tags"] = BookmarksHelper.join_tags(tag_array)
        result_hash["bookmark"] = bmapping.bookmark
        @search_results << result_hash
      end
    end
  end

 #Listing all the bookmarks for a topic
  def view_review_bookmarks

    #NExt few lines can be directly obtained from others' work view itself.
    
    #Reviewer
    @participant = AssignmentParticipant.find(params[:id])
    return unless current_user_id?(@participant.user_id)
    
    @assignment  = @participant.assignment
    
    if @assignment.team_assignment
      @review_mappings = TeamReviewResponseMap.find_all_by_reviewer_id(@participant.id)
    else           
      @review_mappings = ParticipantReviewResponseMap.find_all_by_reviewer_id(@participant.id)
    end
	
    @review_mappings.each do | map | 
      if @assignment.team_assignment?
        participant = AssignmentTeam.get_first_member(map.reviewee_id)
      else
        participant = map.reviewee 
      end

      if participant 

	    #For each topic that this user is reviewing, we have to display the bmappings for that topic
	    topic = SignUpTopic.find(participant.topic.id)
	    @topics_bookmarks = Hash.new
	    if topic	     
	      bookmarks = Array.new
	      for bmapping in topic.bmappings
		
		bookmark_hash = Hash.new
		bookmark_hash["id"] = bmapping.id
		bookmark_hash["url"] = bmapping.bookmark.url
		bookmark_hash["user"] = bmapping.user.name
		bookmark_hash["title"] = bmapping.title
		bookmark_hash["description"] = bmapping.description
		bookmark_hash["copied_by"] = bmapping.bookmark.user_count
		bookmark_hash["created_at"] = bmapping.date_created
		# Now retrieving tags for this user-bookmark mapping
		# First retrieve all the tag_ids mapped to the BMapping id.
		# Then retrieve all the tag names of the tag_ids picked up.
		# Append all these into a comma separated string, and push them onto the hash
		tag_fetchs = BmappingsTags.find(:all, :conditions=>["bmapping_id=?",bmapping.id])
		tag_array = Array.new
		for tag_fetch in tag_fetchs
		  tag_array << Tag.find(tag_fetch.tag_id).tagname
		end
		bookmark_hash["tags"] = BookmarksHelper.join_tags(tag_array)
		bookmark_hash["bookmark"] = bmapping.bookmark
		bookmarks << bookmark_hash
	      end

	    @topics_bookmarks[participant.topic.topic_name] = bookmarks
	    end
      end 
    end
 end

   # Viewing a particualr bookmark
  def view
    @bookmark_mapping_id = params[:id]
    @bookmark_mapping = Bmapping.find(params[:id])
    @result_tuple = Hash.new
    @result_tuple["bmapping_id"] = @bookmark_mapping.id
    @result_tuple["bookmark_id"] = @bookmark_mapping.bookmark_id
    @result_tuple["owner"] = @bookmark_mapping.user.name
    @result_tuple["title"] = @bookmark_mapping.title
    @result_tuple["discoverer"] = User.find(@bookmark_mapping.bookmark.discoverer_user_id).name
    @result_tuple["description"] = @bookmark_mapping.description
    @result_tuple["url"] = @bookmark_mapping.bookmark.url
    @result_tuple["user_count"] = @bookmark_mapping.bookmark.user_count
    tag_fetchs = BmappingsTags.find(:all, :conditions =>["bmapping_id = ?",@bookmark_mapping.id])
    tag_array = Array.new
    for tag_fetch in tag_fetchs
      tag_array << Tag.find(tag_fetch.tag_id).tagname
    end
    @result_tuple["tags"] = BookmarksHelper.join_tags(tag_array)
  end
  
  # View bookmarks and search bookmarks of all the user
  def view_bookmarks
    @search_content = ""
    @order_by = ""
    unless params[:s].nil?
      @search_content = params[:s]
    end
    # Viewing all the bookmarks that are present
    if params[:order_by].nil?
      @order_by = "most_recent"
    else
      @order_by = params[:order_by].to_s
    end
    @users_included ="All Included users"
    @method_name = "view_bookmarks"
    # Call the model function with ordrer by parameter
    @search_results = Bookmark.search_alltags_allusers(@order_by)
  end
  
  def edit_bookmark_form
    @bookmark_mapping = Bmapping.find(params[:id])
    @b_id = @bookmark_mapping.id
    @b_url = @bookmark_mapping.bookmark.url
    @b_title = @bookmark_mapping.title
    @b_tags_text = ""
    tag_fetchs = BmappingsTags.find(:all, :conditions=>["bmapping_id = ?",@bookmark_mapping.id])
    tag_array = Array.new
    for tag_fetch in tag_fetchs
      tag_array << Tag.find(tag_fetch.tag_id).tagname
    end
    @b_tags_text = BookmarksHelper.join_tags(tag_array)
    @b_description = @bookmark_mapping.description
  end

  def edit_bookmark
    # Difference between edit and add - new = add new adds tuple if it downt find any,
    # edit tuple modifies only if it finds something
    b_url = params["b_url"]
    b_title = params["b_title"]
    b_tags_text = params["b_tags_text"]
    b_description = params["b_description"]
    session_user = session[:user]
    Bookmark.edit_this_bookmark(b_url, b_title, b_tags_text, b_description, session_user)
    redirect_to(:action => 'manage_bookmarks')
  end

  
end
