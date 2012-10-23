class SurveyDeployment < ActiveRecord::Base
  validates_numericality_of :num_of_students
  validates_presence_of :num_of_students
  validates_presence_of :start_date
  validates_presence_of :end_date
  
  def validate
    if((end_date != nil) && (start_date != nil) && (end_date-start_date)<0) 
      errors.add_to_base("End Date should be in the future of Start Date.")
    end
    if((start_date != nil) && start_date<Time.now)
      errors.add_to_base("Start Date should be in the future.")
    end
    if((end_date != nil) && end_date<Time.now)
      errors.add_to_base("End Date should be in the future.")
    end
    
    if(num_of_students!=nil && num_of_students > User.find_all_by_role_id(Role.student.id).length)
      errors.add(:num_of_students," - Too many students. #{num_of_students} : #{User.find_all_by_role_id(Role.student.id).length}")
    end
      
      
  end
  
end
