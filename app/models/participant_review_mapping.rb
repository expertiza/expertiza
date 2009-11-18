class ParticipantReviewMapping < ReviewMapping
  belongs_to :reviewee, :class_name => "Participant", :foreign_key => "reviewee_id"
  
  #return an array of authors for this mapping
  #ajbudlon, sept 07, 2007  
  def get_participants
    self.reviewee    
  end  
end