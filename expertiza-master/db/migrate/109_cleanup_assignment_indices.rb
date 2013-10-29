class CleanupAssignmentIndices < ActiveRecord::Migration
  # add/remove indices and foreign keys when appropriate
  def self.up  
    change_column :assignments, :course_id, :integer, :null => true
    change_column :assignments, :instructor_id, :integer, :null => true
    change_column :assignments, :review_strategy_id, :integer, :null => true
    change_column :assignments, :mapping_strategy_id, :integer, :null => true
    
    Assignment.find(:all).each{
      | assignment |
      if assignment.course_id.nil? or assignment.course_id == 0 or Course.find(assignment.course_id).nil?
        assignment.update_attribute('course_id',nil)
      end
      
      if assignment.instructor_id.nil? or assignment.instructor_id == 0 or User.find(assignment.instructor_id).nil?
        assignment.update_attribute('instructor_id',nil)
      end
      
      if assignment.review_strategy_id.nil? or assignment.review_strategy_id == 0 or ReviewStrategy.find(assignment.review_strategy_id).nil?
        assignment.update_attribute('review_strategy_id',nil)
      end

      if assignment.mapping_strategy_id.nil? or assignment.mapping_strategy_id == 0 or MappingStrategy.find(assignment.mapping_strategy_id).nil?
        assignment.update_attribute('mapping_strategy_id',nil)
      end      
    }    
    
    
    execute "ALTER TABLE `assignments` 
             ADD CONSTRAINT `fk_assignments_instructors`
             FOREIGN KEY (instructor_id) references users(id)"
             
    execute "ALTER TABLE `assignments` 
             ADD CONSTRAINT `fk_assignments_courses`
             FOREIGN KEY (course_id) references courses(id)"
             
    execute "ALTER TABLE `assignments` 
             ADD CONSTRAINT `fk_assignments_review_strategies`
             FOREIGN KEY (review_strategy_id) references review_strategies(id)"  
             
    execute "ALTER TABLE `assignments` 
             ADD CONSTRAINT `fk_assignments_mapping_strategies`
             FOREIGN KEY (mapping_strategy_id) references mapping_strategies(id)"  
  end     

  def self.down
  end
end
