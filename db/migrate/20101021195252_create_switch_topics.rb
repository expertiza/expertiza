class CreateSwitchTopics < ActiveRecord::Migration
  def self.up
    create_table :switch_topics do |t|
      t.string :userid
      t.string :unityid
      t.integer :assignment_id
      t.integer :topic_id

      t.timestamps
    end   
    # topic_id and asssignment_id are foreign keys in this table
    # Since assignment_id is a foreign key in this table, index is created for the same. Same for topic_id as well
    # On delete Cascade will truncate the child table automatically when a parent table is truncated. 
    add_index "switch_topics", ["assignment_id"], :name => "fk_switch_topics_assignments"
    
          execute "alter table switch_topics
             add constraint fk_switch_topics_assignments
             foreign key (assignment_id) references assignments(id) ON DELETE CASCADE"
             
    add_index "switch_topics", ["topic_id"], :name => "fk_switch_topics_topics"
    
          execute "alter table switch_topics
             add constraint fk_switch_topics_topics
             foreign key (topic_id) references sign_up_topics(id) ON DELETE CASCADE"
 
#While creating the switch deadline table, we insert into the table deadline types, the new type of deadline
#switch_topics
execute "INSERT INTO `deadline_types` VALUES  (6,'switch_topics');"
end
  def self.down
    drop_table :switch_topics
  end
  
end
