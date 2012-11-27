class CalculatedPenalty < ActiveRecord::Base
     belongs_to :user , :class_name => 'User', :foreign_key => 'instructor_id'
     belongs_to :deadline_type,  :class_name => 'User', :foreign_key => 'deadline_type_id'


end