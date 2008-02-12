class CreateSubmissionWeblinks < ActiveRecord::Migration
  def self.up
    create_table :submission_weblinks do |t|
      t.column :assignment_id, :integer # the assignment to which this link belongs
      t.column :participant_id, :integer # the participant which submitted this link
      t.column :link, :text # the URL which the participant provided
    end
    
    execute "alter table submission_weblinks 
             add constraint fk_assignments_submission_weblinks
             foreign key (assignment_id) references assignments(id)"
    execute "alter table submission_weblinks 
             add constraint fk_participants_submission_weblinks
             foreign key (participant_id) references participants(id)"

  end

  def self.down
    drop_table :submission_weblinks
  end
end
