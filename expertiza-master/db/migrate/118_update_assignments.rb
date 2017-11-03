class UpdateAssignments < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE assignments
              ADD COLUMN staggered_deadline BOOLEAN"
    execute "ALTER TABLE assignments
              ADD COLUMN start_date DATETIME"  
  end

  def self.down
  end
end
