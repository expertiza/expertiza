class CreateSubmissionWeblinks < ActiveRecord::Migration
  def self.up
    create_table :submission_weblinks do |t|
      t.column :participant_id, :integer # the participant which submitted this link
      t.column :link, :text # the URL which the participant provided
    end
    
    execute "alter table submission_weblinks 
             add constraint fk_participants_submission_weblinks
             foreign key (participant_id) references participants(id)"

  end

  def self.down
    drop_table :submission_weblinks
  end
end
