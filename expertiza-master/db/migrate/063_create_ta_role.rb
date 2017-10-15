class CreateTaRole < ActiveRecord::Migration
  def self.up
     
    parent = Role.find_by_name("Student")
    child = Role.find_by_name("Instructor")
    ta_role = Role.find_or_create_by(name: "Teaching Assistant")
    ta_role.parent_id = parent.id
    ta_role.save
    
    child.parent_id = ta_role.id
    child.save
    
    Role.rebuild_cache
  end

  def self.down
  end
end
