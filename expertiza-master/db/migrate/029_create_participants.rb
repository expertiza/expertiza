class CreateParticipants < ActiveRecord::Migration
  def self.up
  create_table "participants", :force => true do |t|
    t.column "submit_allowed", :boolean, :default => true
    t.column "review_allowed", :boolean, :default => true
    t.column "user_id", :integer
    t.column "assignment_id", :integer
    t.column "directory_num", :integer
    t.column "submitted_at", :datetime
    t.column "topic", :string
    t.column "permission_granted", :boolean
    t.column "penalty_accumulated", :integer, :limit => 10, :default => 0, :null => false
    t.column "submitted_hyperlink", :string, :limit => 500
  end

  add_index "participants", ["user_id"], :name => "fk_participant_users"

  execute "alter table participants 
             add constraint fk_participant_users
             foreign key (user_id) references users(id)"

  
  add_index "participants", ["assignment_id"], :name => "fk_participant_assignments"

  execute "alter table participants 
             add constraint fk_participant_assignments
             foreign key (assignment_id) references assignments(id)"

  end

  def self.down
     drop_table "participants"
  end
end
