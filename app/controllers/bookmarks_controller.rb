class BookmarksController < ApplicationController
  def add_bookmark_form
    puts "#########################"
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
    prepare_string(b_url)
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
        tag_fetchs = Qualifier.find(:all, :conditions=>["bmapping_id=?",bmapping.id])
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

 def prepare_string(mystring)
    # For a given string remove all spaces to the left, right, and downcase all of it
    # Specifically done to urls, and search tags
    b_tag1 = mystring.lstrip
    b_tag2 = b_tag1.rstrip
    b_tag3 = b_tag2.downcase
    return b_tag3
  end
end
