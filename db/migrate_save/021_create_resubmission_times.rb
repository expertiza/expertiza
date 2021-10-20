class CreateResubmissionTimes < ActiveRecord::Migration
  def self.up
    create_table :resubmission_times do |t|
      t.column :participant_id, :integer
      t.column :resubmitted_at, :datetime
    end
    execute "alter table resubmission_times
             add constraint fk_resubmission_times_participants
             foreign key (participant_id) references participants(id)"
  end

  def self.down
    drop_table :resubmission_times
  end
end
