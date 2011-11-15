<<<<<<< HEAD
class Invitation < ActiveRecord::Base
  belongs_to :to_user, :class_name => "User", :foreign_key => "to_id"
  belongs_to :from_user, :class_name => "User", :foreign_key => "from_id"
  
end
=======
class Invitation < ActiveRecord::Base
  belongs_to :to_user, :class_name => "User", :foreign_key => "to_id"
  belongs_to :from_user, :class_name => "User", :foreign_key => "from_id"
  
end
>>>>>>> c4cd6ee2acd0c2721114a9165e8bf6050a7dd1ee
