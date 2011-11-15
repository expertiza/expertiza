<<<<<<< HEAD
=======
<<<<<<< HEAD
<<<<<<< HEAD
>>>>>>> 126e61ecf11c9abb3ccdba784bf9528251d30eb0
class Invitation < ActiveRecord::Base
  belongs_to :to_user, :class_name => "User", :foreign_key => "to_id"
  belongs_to :from_user, :class_name => "User", :foreign_key => "from_id"
  
end
<<<<<<< HEAD
=======
=======
class Invitation < ActiveRecord::Base
  belongs_to :to_user, :class_name => "User", :foreign_key => "to_id"
  belongs_to :from_user, :class_name => "User", :foreign_key => "from_id"
  
end
>>>>>>> c4cd6ee2acd0c2721114a9165e8bf6050a7dd1ee
=======
class Invitation < ActiveRecord::Base
  belongs_to :to_user, :class_name => "User", :foreign_key => "to_id"
  belongs_to :from_user, :class_name => "User", :foreign_key => "from_id"
  
end
>>>>>>> c4cd6ee2acd0c2721114a9165e8bf6050a7dd1ee
>>>>>>> 126e61ecf11c9abb3ccdba784bf9528251d30eb0
