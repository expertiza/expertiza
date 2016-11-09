class CreateParticipants < ActiveRecord::Migration
  def self.up
    create_table :participants do |t|
      t.column :submit_allowed, :boolean  # true if user is allowed to submit to this assignment
      t.column :review_allowed, :boolean
      t.column :user_id, :integer
      t.column :assignment_id, :integer
      t.column :directory_num, :integer  # number of user's submission directory for this assignment
      t.column :submitted_at, :datetime # time that original version was submitted, i.e., time that the _last_ file was submitted to that version
      # note that lateness of REsubmissions is tracked in the resubmission_times table.  The lateness of resubmissions is cumulative; e.g., if you're late by 2 days on the first resubmission and late by 1 day on the second, you're late by 3 days on resubmissions overall
      t.column :topic, :string # the topic, if any, that the user selected in Shimmer
      t.column :permission_granted, :boolean # whether user has granted permission to "publish" this work
    end
    execute "alter table participants
             add constraint fk_participant_users
             foreign key (user_id) references users(id)"
    execute "alter table participants
             add constraint fk_participant_assignments
             foreign key (assignment_id) references assignments(id)"
  end

  def self.down
    drop_table :participants
  end
end
