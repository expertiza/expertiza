class CreateSwitchTopics < ActiveRecord::Migration
  def self.up
    create_table :switch_topics do |t|
      t.string :userid
      t.string :unityid
      t.integer :assignment_id
      t.integer :topic_id

      t.timestamps
    end
  
  
#    add_index "switch_topics", ["userid"], :name => "fk_switch_topics_users"
#      execute "alter table switch_topics
#             add constraint fk_switch_topics_users
#             foreign key (userid) references users(id)" 
             
    add_index "switch_topics", ["assignment_id"], :name => "fk_switch_topics_assignments"
    
          execute "alter table switch_topics
             add constraint fk_switch_topics_assignments
             foreign key (assignment_id) references assignments(id) ON DELETE CASCADE"
             
    add_index "switch_topics", ["topic_id"], :name => "fk_switch_topics_topics"
    
          execute "alter table switch_topics
             add constraint fk_switch_topics_topics
             foreign key (topic_id) references sign_up_topics(id) ON DELETE CASCADE"
 

end
  def self.down
    drop_table :switch_topics
  end
  
end
