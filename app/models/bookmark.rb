class Bookmark < ActiveRecord::Base
  has_many(:bmappings)

  # -------------------- CRUD operations for bookmark -------------------- #
 def self.add_topic_bookmark(b_url, b_title, b_tags_text, b_description,session_user, topicid)
    # Check if the bookmark exists and add / edit based on that
    status_string = Bookmark.check_bookmark_and_mapping(b_url,session_user)
    if(status_string == "url_not_found"|| status_string == "mapping_not_found")
      Bookmark.add_bookmark(b_url, b_title, b_tags_text, b_description,session_user,topicid)
    elsif(status_string == "mapping_exists")
      #Bookmark.edit_this_bookmark(b_url, b_title, b_tags_text, b_description,session_user)
    end
  end

 # Add bookmark and bmapping.
  # Check if url exists, bmapping exists, if it does - edit, if it doesnt - add
  def self.add_this_bookmark(b_url, b_title, b_tags_text, b_description,session_user)
    status_string = Bookmark.check_bookmark_and_mapping(b_url,session_user)
    if (status_string == "url_not_found"|| status_string == "mapping_not_found")
      Bookmark.adding_bookmark(b_url, b_title, b_tags_text, b_description,session_user)
    elsif (status_string == "mapping_exists")
      #Bookmark.edit_this_bookmark(b_url, b_title, b_tags_text, b_description,session_user)
    end
  end


# Utility methods
# -----------------------------------------------

# Check if bookmark url exists.
  # If the url does exists, check if the user has this bookmark in his repository
  def self.check_bookmark_and_mapping (b_url, session_user)
   bookmark_resource = Bookmark.find(:first, :conditions=>["url = ?",b_url])
   return_string = ""
    if bookmark_resource.nil?
      return_string = "url_not_found"
    else
      bookmark_user_mapping = Bmapping.find(:first, :conditions =>["user_id = ? and bookmark_id = ?", session_user.id, bookmark_resource.id])
      if bookmark_user_mapping.nil?
        return_string = "mapping_not_found"
      else
        return_string = "mapping_exists"
      end
    end
    return return_string
  end

  # Adds a bookmark and its various associations
  def self.add_bookmark(b_url, b_title, b_tags_text, b_description,session_user,topicid)
    bookmark_resource = Bookmark.find(:first, :conditions => ["url = ?",b_url])
    flag = 0
    # Bookmark with the same url does not exists.
    if bookmark_resource.nil?
      # Add the newly discovered bookmark
      @bookmarkid = add_new_bookmark(b_url,session_user.id)
      # Add its associations to a user
      @bmappingid = add_bmapping(@bookmarkid, b_title, session_user.id, b_description,b_tags_text )
      # Add its association to the sign up topic
      add_bmapping_signuptopic(topicid, @bmappingid)
    # Bookmark with the same url exists.
    else
      @bmapping = Bmapping.find_by_bookmark_id_and_user_id(bookmark_resource.id,session_user.id)
      # Bookmark with the same user exist.
      unless @bmapping.nil?
        @topic = SignUpTopic.find(topicid)
        unless @topic.nil?
          @topic.bmappings.each do |mapping|
            if (mapping.id == @bmapping.id)
              #Bookmark.edit_this_bookmark(b_url, b_title, b_tags_text, b_description,session_user)
              flag = 1
            end
          end
        end
        # Signup Topic does not exists
        if flag == 0
          add_bmapping_signuptopic(topicid, @bmapping.id)
        end
      # Bookmark with same user does not exist.
      else
        # Increment user count
        bookmark_resource.user_count = bookmark_resource.user_count + 1
        bookmark_resource.save
        # Add its association with the user
        @bmappingid = add_bmapping(bookmark_resource.id, b_title, session_user.id, b_description,b_tags_text)
        add_bmapping_signuptopic(topicid, @bmappingid)
      end
    end
end

  # Check if bookmark url exists.
  # If the url does exists, check if the user has this bookmark in his repository
  def self.check_bookmark_and_mapping (b_url, session_user)
   bookmark_resource = Bookmark.find(:first, :conditions=>["url = ?",b_url])
   return_string = ""
    if bookmark_resource.nil?
      return_string = "url_not_found"
    else
      bookmark_user_mapping = Bmapping.find(:first, :conditions =>["user_id = ? and bookmark_id = ?", session_user.id, bookmark_resource.id])
      if bookmark_user_mapping.nil?
        return_string = "mapping_not_found"
      else
        return_string = "mapping_exists"
      end
    end
    return return_string
  end

  # Adds a new bookmark
def self.add_new_bookmark(b_url,user_id)
    # Create a resource
    bookmark_resource = Bookmark.new
    bookmark_resource.url = b_url
    bookmark_resource.discoverer_user_id = user_id
    bookmark_resource.user_count = 1
    bookmark_resource.save
    return bookmark_resource.id
end

  # Add bookmark - user association with its meta fields
def self.add_bmapping(bid, b_title, user_id, b_description,b_tags_text)
    bookmark_user_mapping = Bmapping.new
    bookmark_user_mapping.bookmark_id = bid
    bookmark_user_mapping.title = b_title
    bookmark_user_mapping.description = b_description
    bookmark_user_mapping.user_id =user_id
    current_timestamp = Time.now
    bookmark_user_mapping.date_created = current_timestamp
    bookmark_user_mapping.date_modified = current_timestamp
    bookmark_user_mapping.save
    # Add tags
    # tags come in as a text, separating them into a array
=begin
    tag_array = BookmarksHelper.separate_tags(b_tags_text)
    for each_tag in tag_array
      # Look for each tag that is present in tags, if not make them, then make the BTU entry
      tag_tuple = Tag.find(:first, :conditions =>["tagname = ?",each_tag])
      if tag_tuple.nil?
        tag_tuple = Tag.new
        tag_tuple.tagname = each_tag
        tag_tuple.save
      end
      # Check if there is an entry for this tag, this user and this bookmark (via bmappings table)
      btu_tuple = BmappingsTags.find(:first, :conditions =>[ "tag_id = ? and bmapping_id = ?", tag_tuple.id, bookmark_user_mapping.id] )
      if btu_tuple.nil?
        btu_tuple = BmappingsTags.new
        btu_tuple.tag_id = tag_tuple.id
        btu_tuple.bmapping_id = bookmark_user_mapping.id
        btu_tuple.save
      end
    end
=end
    return bookmark_user_mapping.id
end

  # Associate bmapping to the sign up topic
def self.add_bmapping_signuptopic(topicid, bmappingid)
    @topic = SignUpTopic.find(topicid)
    @bmapping = Bmapping.find(bmappingid)
    unless (@topic.nil? && @bmapping.nil?)
      @topic.bmappings << @bmapping
      @topic.save
    end
end



end

