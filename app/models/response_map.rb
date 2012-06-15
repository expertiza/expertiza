class ResponseMap < ActiveRecord::Base
  belongs_to :reviewer, :class_name => 'Participant', :foreign_key => 'reviewer_id'
  has_one :response, :class_name => 'Response', :foreign_key => 'map_id'
  has_many :metareview_response_maps, :class_name => 'MetareviewResponseMap', :foreign_key => 'reviewed_object_id'
  has_many :metareview_responses, :source => :responses, :finder_sql => 'SELECT meta.* FROM responses r, response_maps meta, response_maps rev WHERE r.map_id = m.id AND m.type = \'MetaeviewResponseMap\' AND m.reviewee_id = p.id AND p.id = #{id}'
  
  # return latest versions of the responses
  def self.get_assessments_for(participant)
    responses = Array.new   
    
    if participant
      @array_sort=Array.new
      @sort_to=Array.new

      #get all the versions
      maps = find(:all, :conditions => ['reviewee_id = ? and type = ?',participant.id,self.to_s])
      maps.each{ |map|
        if map.response
             @all_resp=Response.all
          for element in @all_resp
            if(element.map_id==map.id)
                @array_sort << element
            end
          end
             #sort all versions in descending order and get the latest one.
          @sort_to=@array_sort.sort { |m1,m2|(m1.version_num and m2.version_num) ? m2.version_num <=> m1.version_num : (m1.version_num ? -1 : 1)}
          responses << @sort_to[0]
          @array_sort.clear
          @sort_to.clear
        end
      }
      #responses = Response.find(:all, :include => :map, :conditions => ['reviewee_id = ? and type = ?',participant.id, self.to_s])      
      responses.sort! {|a,b| a.map.reviewer.fullname <=> b.map.reviewer.fullname }
      end
    return responses    
  end 
  
  # Placeholder method, override in derived classes if required.
  def get_all_versions()
    return []
  end
  
  def delete(force = nil)
    if self.response != nil and !force
      raise "A response exists for this mapping."
    elsif self.response != nil
      self.response.delete
    end    
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
    return MetareviewResponseMap.count(:conditions => ['reviewee_id = ? AND reviewer_id = ? AND reviewed_object_id = ?', 
      reviewer.id, metareviewer.id, self.id]) > 0
  end
  
  # Assigns a metareviewer to this review (response)
  # @param[in] metareviewer AssignmentParticipant object 
  def assign_metareviewer(metareviewer)
    MetareviewResponseMap.create(:reviewed_object_id => self.id,
      :reviewer_id => metareviewer.id, :reviewee_id => reviewer.id)
  end
  
  def self.delete_mappings(mappings, force=nil)
    failedCount = 0
    mappings.each{
       |mapping|
       assignment_id = mapping.assignment.id
       begin
         mapping.delete(force)
       rescue
         failedCount += 1
       end
    }
    return failedCount
  end

end
