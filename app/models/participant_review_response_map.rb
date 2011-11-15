<<<<<<< HEAD
<<<<<<< HEAD
class ParticipantReviewResponseMap < ReviewResponseMap
  belongs_to :reviewee, :class_name => 'Participant', :foreign_key => 'reviewee_id'
  belongs_to :contributor, :class_name => 'Participant', :foreign_key => 'reviewee_id' 
=======
class ParticipantReviewResponseMap < ReviewResponseMap
  belongs_to :reviewee, :class_name => 'Participant', :foreign_key => 'reviewee_id'
  belongs_to :contributor, :class_name => 'Participant', :foreign_key => 'reviewee_id' 
>>>>>>> c4cd6ee2acd0c2721114a9165e8bf6050a7dd1ee
=======
class ParticipantReviewResponseMap < ReviewResponseMap
  belongs_to :reviewee, :class_name => 'Participant', :foreign_key => 'reviewee_id'
  belongs_to :contributor, :class_name => 'Participant', :foreign_key => 'reviewee_id' 
>>>>>>> c4cd6ee2acd0c2721114a9165e8bf6050a7dd1ee
end