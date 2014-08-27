class BookmarksController < ApplicationController

  def action_allowed?
    case params[:action]
    when 'add_bookmark_form', 'add_bookmark', 'view_topic_bookmarks'
      current_role_name.eql? 'Student'
    end
  end

  def add_bookmark_form
    # Fields: b_url b_type, b_title b_tags_text, b_type b_description
    @b_url = ""
    @b_title = ""
    @b_tags_text = ""
    @b_description = ""
    @topic_id = params[:id]
    return @topic_id
  end

  def show
    redirect_to(:action => 'view_bookmarks')
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
    @s=""
    @user=session[:user].id
    @order_by="most_recent"
    @search_result ="A B C"
  end

  def managing_bookmarks
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
    @method_name = "managing_bookmarks"
    # Call the model function with order by parameter
    @search_results = Bookmark.search_alltags_foruser(@my_user_id, @order_by)
  end

  #Listing all the bookmarks for a topic
  def view_topic_bookmarks
    @current_user = User.find(session[:user].id)
    @assignment_id=params[:assignment_id]
    @topic = SignUpTopic.find(params[:id])
    @topic_bookmark_rating_rubric = BookmarkRatingRubric.find(@topic.bookmark_rating_rubric_id) unless @topic.bookmark_rating_rubric_id.nil?
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
        result_hash["bmapping_rating"] = bmapping.cumulative_rating
        # Now retrieving tags for this user-bookmark mapping
        # First retrieve all the tag_ids mapped to the BMapping id.
        # Then retrieve all the tag names of the tag_ids picked up.
        # Append all these into a comma separated string, and push them onto the hash
        tag_fetchs = BmappingsTags.where(["bmapping_id=?",bmapping.id])
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

  #Listing all the bookmarks for the topic being reviewed
  def view_review_bookmarks

    #NExt few lines can be directly obtained from others' work view itself.

    #Reviewer
    @participant = AssignmentParticipant.find(params[:id])
    return unless current_user_id?(@participant.user_id)

    @assignment  = @participant.assignment

    if @assignment.team_assignment
      @review_mappings = TeamReviewResponseMap.where(reviewer_id: @participant.id)
    else
      @review_mappings = ParticipantReviewResponseMap.where(reviewer_id: @participant.id)
    end

    @topics_bookmarks = Hash.new

    @review_mappings.each do | map |
      if @assignment.team_assignment?
        participant = AssignmentTeam.get_first_member(map.reviewee_id)
      else
        participant = map.reviewee
      end

      if participant

        #For each topic that this user is reviewing, we have to display the bmappings for that topic
        topic = SignUpTopic.find(participant.topic.id)
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
            tag_fetchs = BmappingsTags.where(["bmapping_id=?",bmapping.id])
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
    tag_fetchs = BmappingsTags.where(["bmapping_id = ?",@bookmark_mapping.id])
    tag_array = Array.new
    for tag_fetch in tag_fetchs
      tag_array << Tag.find(tag_fetch.tag_id).tagname
    end
    @result_tuple["tags"] = BookmarksHelper.join_tags(tag_array)
  end

  # View bookmarks and search bookmarks of all the user
  def view_bookmarks
    @s=""
    @order_by="most_recent"
    @search_result ="A B C"
  end

  def viewing_bookmarks
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
    @method_name = "managing_bookmarks"
    # Call the model function with order by parameter
    @search_results = Bookmark.search_alltags_foruser(@my_user_id, @order_by)
  end

  def edit_bookmark_form
    @bookmark_mapping = Bmapping.find(params[:id])
    @b_id = @bookmark_mapping.id
    @b_url = @bookmark_mapping.bookmark.url
    @b_title = @bookmark_mapping.title
    @b_tags_text = ""
    tag_fetchs = BmappingsTags.where(["bmapping_id = ?",@bookmark_mapping.id])
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
    @my_user = @my_user_temp.gsub(/value/, '');


    @search_array  = BookmarksHelper.separate_tags( @search_string)

    @method_name = "search_bookmarks"
    @search_results = Array.new
    if (@my_user != "all_users")
      @search_results = Bookmark.search_fortags_foruser(@search_array, @my_user, @order_by)
      print(@search_results)
      print("Chutya1")
    else

      @search_results = Bookmark.search_fortags_allusers(@search_array, @order_by)
      print(@search_results)
      print("Chutya2")
    end
    if(@my_user == "all_users")
      render :action => "view_bookmarks"
      print("Chutya3")
    else
      render :action =>"manage_bookmarks"

      print(@search_results.count)
      print("Chutya4")
    end
    print("Chutya5")
    end


  def add_rating_rubric_form
    @rating_rubric = BookmarkRatingRubric.new
  end


  def create



  end



  def create_rating_rubric
    @rating_rubric = BookmarkRatingRubric.create(:display_text => params[:display_text].strip, :minimum_rating => params[:minimum_rating], :maximum_rating => params[:maximum_rating])
    if @rating_rubric.errors.empty?
      redirect_to(:action => :view_rating_rubrics)
    else
      render(:action => :add_rating_rubric_form)
    end
  end

  def edit_rating_rubric_form
    @rating_rubric = BookmarkRatingRubric.find(params[:id])
  end

  def update_rating_rubric
    @rating_rubric = BookmarkRatingRubric.find(params[:id])
    @rating_rubric.display_text = params[:display_text].strip
    @rating_rubric.minimum_rating = params[:minimum_rating]
    @rating_rubric.maximum_rating = params[:maximum_rating]
    @rating_rubric.save
    if @rating_rubric.errors.empty?
      redirect_to(:action => :view_rating_rubrics)
    else
      render(:action => :edit_rating_rubric_form)
    end
  end

  def view_rating_rubrics
    @rating_rubrics = BookmarkRatingRubric.all
  end

  def save_rating
    @current_user = User.find(session[:user].id)
    # Check if the user has already rated the bmapping.
    if old_rating = @current_user.bookmark_rated?(params[:bmapping_id])
      old_rating.rating = params[:bookmark_rating]
      old_rating.save
    else
      BmappingRatings.create(:bmapping_id => params[:bmapping_id], :user_id => @current_user.id, :rating => params[:bookmark_rating])
    end
    redirect_to(:action => :view_topic_bookmarks, :id => params[:topic_bookmark_id], :assignment_id => params[:assignment_id])
  end

  def add_tag_bookmark
    @tag = Tag.new
  end

  def create_tag_bookmark
    @tag = Tag.new(params[:tag])
    @tag.save
    @bmapping_tag = BmappingsTags.new
    @bmapping_tag.bmapping_id = params[:bmapping_id]
    @bmapping_tag.tag_id = @tag.id
    @bmapping_tag.save
    redirect_to(:action =>"view", :id =>params[:bmapping_id])
  end

  def bookmark_rate
    @current_user = User.find(session[:user].id)
    @assignment_id=params[:assignment_id]
    @topic = SignUpTopic.find(params[:id])
    @topic_bookmark_rating_rubric = BookmarkRatingRubric.find(@topic.bookmark_rating_rubric_id) unless @topic.bookmark_rating_rubric_id.nil?
    @search_results = params[:bookmark_id]
  end
end
