class ResponseMap < ActiveRecord::Base
  has_one :response, foreign_key: 'map_id', dependent: :destroy
  belongs_to :reviewer, :class_name => 'Participant', :foreign_key => 'reviewer_id',:dependent => :destroy

  def map_id
    id
  end

  # return latest versions of the responses
  def self.get_assessments_for(participant)


    responses = Array.new
    stime=Time.now
    if participant

      @array_sort=Array.new
      @sort_to=Array.new
      @test = Array.new

      #get all the versions
      maps = where(reviewee_id: participant.id)
      time1 = Time.now
      # puts "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$     get_assessments_for1 Current Time1 : " + time1.inspect
      maps.each { |map|
        if map.response
          time10 = Time.now
          puts "**********************************     get_assessments_for1 Current Time10 : " + time10.inspect
          @all_resp=Response.all

          time11 = Time.now
          puts "**********************************     get_assessments_for1 Current Time11 : " + time11.inspect
          for element in @all_resp
            # puts "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& #{@map.map_id}"
            if (element.map_id == map.map_id)
              # puts element.map_id
              # puts map.map_id
              @array_sort << element
              @test << map
              # puts "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& #{@array_sort}"
              # puts "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& #{@map.map_id}"
            end
          end
          time12 = Time.now
          puts "**********************************     get_assessments_for1 Current Time12 : " + time12.inspect
          #sort all versions in descending order and get the latest one.
          @sort_to=@array_sort.sort { |m1, m2| (m1.version_num and m2.version_num) ? m2.version_num <=> m1.version_num : (m1.version_num ? -1 : 1) }
          responses << @sort_to[0]
          # puts "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&00 #{@array_sort[0]}"
          @array_sort.clear
          @sort_to.clear
        end
      }
      # time2 = Time.now
      # puts "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$     get_assessments_for1 Current Time2 : " + time2.inspect
      responses.sort! { |a, b| a.map.reviewer.fullname <=> b.map.reviewer.fullname }
    end
    time3 = Time.now
    puts "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$     get_assessments_for1 Current Time3 : " + time3.inspect
    return responses
  end

  # return latest versions of the response given by reviewer
  def self.get_reviewer_assessments_for(participant, reviewer)
    map = where(reviewee_id: participant.id, reviewer_id: reviewer.id)
    return Response.where(map_id: map).sort { |m1, m2| (m1.version_num and m2.version_num) ? m2.version_num <=> m1.version_num : (m1.version_num ? -1 : 1) }[0]
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
    MetareviewResponseMap.where(reviewee_id: self.reviewer.id, reviewer_id: metareviewer.id, reviewed_object_id: self.id).count() > 0
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
end
