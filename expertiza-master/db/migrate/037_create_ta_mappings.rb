class CreateTaMappings < ActiveRecord::Migration
  def self.up
    create_table :ta_mappings do |t|
      t.column :ta_id, :integer
      t.column :course_id, :integer
    end
    
  add_index "ta_mappings", ["ta_id"], :name => "fk_ta_mappings_ta_id"

  execute "alter table ta_mappings 
             add constraint fk_ta_mappings_ta_id
             foreign key (ta_id) references users(id)"
             
             
  add_index "ta_mappings", ["course_id"], :name => "fk_ta_mappings_course_id"

  execute "alter table ta_mappings 
             add constraint fk_ta_mappings_course_id
             foreign key (course_id) references courses(id)"
    
  end

  def self.down
    
    execute "ALTER TABLE ta_mappings 
             DROP FOREIGN KEY fk_ta_mappings_course_id"
    
    execute "ALTER TABLE ta_mappings 
             DROP FOREIGN KEY fk_ta_mappings_ta_id"
             
    
    drop_table :ta_mappings
  end
end
