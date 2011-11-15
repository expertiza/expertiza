<<<<<<< HEAD
=======
<<<<<<< HEAD
<<<<<<< HEAD
>>>>>>> 126e61ecf11c9abb3ccdba784bf9528251d30eb0
class TeamReviewResponseMap < ReviewResponseMap
  belongs_to :reviewee, :class_name => 'Team', :foreign_key => 'reviewee_id'
  belongs_to :contributor, :class_name => 'Team', :foreign_key => 'reviewee_id'

<<<<<<< HEAD
=======
=======
class TeamReviewResponseMap < ReviewResponseMap
  belongs_to :reviewee, :class_name => 'Team', :foreign_key => 'reviewee_id'
  belongs_to :contributor, :class_name => 'Team', :foreign_key => 'reviewee_id'

>>>>>>> c4cd6ee2acd0c2721114a9165e8bf6050a7dd1ee
=======
class TeamReviewResponseMap < ReviewResponseMap
  belongs_to :reviewee, :class_name => 'Team', :foreign_key => 'reviewee_id'
  belongs_to :contributor, :class_name => 'Team', :foreign_key => 'reviewee_id'

>>>>>>> c4cd6ee2acd0c2721114a9165e8bf6050a7dd1ee
>>>>>>> 126e61ecf11c9abb3ccdba784bf9528251d30eb0
end