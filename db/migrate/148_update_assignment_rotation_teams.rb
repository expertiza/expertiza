class UpdateAssignmentRotationTeams < ActiveRecord::Migration
  def self.up
    #rotationCondition 0=> rotation not required, 1 => course wise, 2 => course + category wise
    execute "ALTER TABLE assignments
              ADD COLUMN rotation_condition INT"
    execute "ALTER TABLE assignments
              ADD COLUMN category_id INT"
    execute "ALTER TABLE assignments
              ADD COLUMN max_num_times_can_partner INT"
    execute "ALTER TABLE assignments
              ADD CONSTRAINT fk_category_id
              FOREIGN KEY (category_id) REFERENCES categories(id)"  
  end  

  def self.down
    execute "ALTER TABLE assignments
              DROP FOREIGN KEY fk_category_id"
    execute "ALTER TABLE assignments
              REMOVE COLUMN max_num_times_can_partner"    
    execute "ALTER TABLE assignments
              REMOVE COLUMN rotation_condition"
    execute "ALTER TABLE assignments
              REMOVE COLUMN category_id"
  end
end