class CreateResubmissionTimes < ActiveRecord::Migration
  def self.up
  create_table "resubmission_times", :force => true do |t|
    t.column "participant_id", :integer
    t.column "resubmitted_at", :datetime
  end

  add_index "resubmission_times", ["participant_id"], :name => "fk_resubmission_times_participants"

  execute "alter table resubmission_times
             add constraint fk_resubmission_times_participants
             foreign key (participant_id) references participants(id)"

  
  end

  def self.down
      drop_table "resubmission_times"
  end
end
