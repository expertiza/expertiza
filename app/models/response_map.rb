class ResponseMap < Response

  alias_attribute :id, :map_id

  def response_id
    self['id']
  end

  # return latest versions of the responses
  def self.get_assessments_for(participant)
    responses = Array.new

    if participant

      @array_sort=Array.new
      @sort_to=Array.new

      #get all the versions
      maps = find_all_by_reviewee_id(participant.id)
      maps.each { |map|
        if map.response
          @all_resp=Response.all
          for element in @all_resp
            if (element.map_id == map.id)
              @array_sort << element
            end
          end
          #sort all versions in descending order and get the latest one.
          @sort_to=@array_sort.sort { |m1, m2| (m1.version_num and m2.version_num) ? m2.version_num <=> m1.version_num : (m1.version_num ? -1 : 1) }
          responses << @sort_to[0]
          @array_sort.clear
          @sort_to.clear
        end
      }
      responses.sort! { |a, b| a.map.reviewer.fullname <=> b.map.reviewer.fullname }
    end
    return responses
  end

  # return latest versions of the response given by reviewer
  def self.get_reviewer_assessments_for(participant, reviewer)
    map = find_all_by_reviewee_id_and_reviewer_id(participant.id, reviewer.id)
    return Response.find_all_by_map_id(map).sort { |m1, m2| (m1.version_num and m2.version_num) ? m2.version_num <=> m1.version_num : (m1.version_num ? -1 : 1) }[0]
  end

  # Placeholder method, override in derived classes if required.
  def get_all_versions()
    return []
  end

  def delete(force = nil)
    self.destroy
  end

  def show_review()
    return nil
  end

  def show_feedback()
    return nil
  end

  # Evaluates whether this response_map was metareviewed by metareviewer
  # @param[in] metareviewer AssignmentParticipant object
  def metareviewed_by?(metareviewer)
    MetareviewResponseMap.find_all_by_reviewee_id_and_reviewer_id_and_reviewed_object_id(self.reviewer.id, metareviewer.id, self.id).count() > 0
  end

  # Assigns a metareviewer to this review (response)
  # @param[in] metareviewer AssignmentParticipant object 
  def assign_metareviewer(metareviewer)
    MetareviewResponseMap.create(:reviewed_object_id => self.id,
                                 :reviewer_id => metareviewer.id, :reviewee_id => reviewer.id)
  end

  def self.delete_mappings(mappings, force=nil)
    failedCount = 0
    mappings.each {
        |mapping|
      begin
        mapping.delete(force)
      rescue
        failedCount += 1
      end
    }
    return failedCount
  end

  def self.find(*args)
    if args.length == 1
      Response.find_by_map_id(args.first)
    else
      super
    end
  end

  def self.find_by_id(*args)
    Response.find_by_map_id(args.first)
  end

  def response
    self
  end
end
