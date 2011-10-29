class ResponseMap < ActiveRecord::Base
  belongs_to :reviewer, :class_name => 'Participant', :foreign_key => 'reviewer_id'
  belongs_to :reviewee, :class_name => 'Participant', :foreign_key => 'reviewee_id'
  has_one :response, :class_name => 'Response', :foreign_key => 'map_id'
  has_many :metareview_response_maps, :class_name => 'MetareviewResponseMap', :foreign_key => 'reviewed_object_id'
  has_many :metareview_responses, :source => :responses, :finder_sql => 'SELECT meta.* FROM responses r, response_maps meta, response_maps rev WHERE r.map_id = m.id AND m.type = \'MetaeviewResponseMap\' AND m.reviewee_id = p.id AND p.id = #{id}'

  # Callbacks
  after_create(:email_reviewer)   
  
  def email_reviewer
    assignment = Assignment.find(:first, [:conditions => "id = #{self.reviewed_object_id}"])
    Mailer.deliver_message (
        {:recipients => self.reviewer.user.email,
         :subject => "You have been added as a reviewer.",
         :body => {
           :first_name => ApplicationHelper::get_user_first_name(self.reviewer.user),
           :assignment => assignment,
           :partial_name => "reviewer_added"
         }
        }
    )
  end
  
  def self.get_assessments_for(participant)
    responses = Array.new   
    
    if participant
      maps = find(:all, :conditions => ['reviewee_id = ? and type = ?', participant.id,self.to_s])
      maps.each{ |map|
        if map.response
          responses << map.response
        end
      }
      #responses = Response.find(:all, :include => :map, :conditions => ['reviewee_id = ? and type = ?',participant.id, self.to_s])      
      responses.sort! {|a,b| a.map.reviewer.fullname <=> b.map.reviewer.fullname }
    end
    return responses    
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
end
