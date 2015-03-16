class Bmapping < ActiveRecord::Base
  belongs_to :user
  belongs_to :bookmark
  has_many :bmappings_tags
  has_and_belongs_to_many :sign_up_topics
  has_many :ratings, :class_name => "BmappingRatings", :foreign_key => "bmapping_id"

  def cumulative_rating
    rating = 0.0
    count = 0
    self.ratings.each do |br|
      rating = rating + br.rating
      count = count + 1
    end
    if count > 0
      return rating/count
    else
      return nil
    end
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

      tag_array = BookmarksHelper.separate_tags(b_tags_text)
      for each_tag in tag_array
        # Look for each tag that is present in tags, if not make them, then make the BTU entry
        tag_tuple = Tag.where(["tagname = ?",each_tag]).first
        if tag_tuple.nil?
          tag_tuple = Tag.new
          tag_tuple.tagname = each_tag
          tag_tuple.save
        end
        # Check if there is an entry for this tag, this user and this bookmark (via bmappings table)
        btu_tuple = BmappingsTag.where([ "tag_id = ? and bmapping_id = ?", tag_tuple.id, bookmark_user_mapping.id] ).first
        if btu_tuple.nil?
          btu_tuple = BmappingsTag.new
          btu_tuple.tag_id = tag_tuple.id
          btu_tuple.bmapping_id = bookmark_user_mapping.id
          btu_tuple.save
        end
      end
        return bookmark_user_mapping.id
    end

      # Associate bmapping to the sign up topic
      def self.add_bmapping_signuptopic(topic_id, bmappingid)
        topic = SignUpTopic.find(topic_id)
        bmapping = Bmapping.find(bmappingid)
        unless (topic.nil? && bmapping.nil?)
          topic.bmappings << bmapping
          topic.save
        end
      end

end

