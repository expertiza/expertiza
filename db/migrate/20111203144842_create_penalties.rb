class CreatePenalties < ActiveRecord::Migration
  def self.up
    create_table :penalties do |t|
      t.integer :assignment_id
      t.datetime :author_feedback_at
      t.datetime :metareviewed1_at
      t.datetime :metareviewed2_at
      t.integer :metareviewee1_id
      t.integer :metareviewee2_id
      t.integer :participant_id
      t.integer :penalty_mins_accumulated
      t.float :penalty_score
      t.datetime :reviewed1_at
      t.datetime :reviewed2_at
      t.integer :reviewee1_id
      t.integer :reviewee2_id
      t.datetime :submitted_at
      t.datetime :teammate_review_at
      t.integer :user_id

      t.timestamps
    end
    add_index "penalties", ["participant_id"], :name => "fk_participants_penalties"

     execute "alter table penalties
                add constraint fk_participants_penalties
                foreign key (participant_id) references participants(id)"

  end

  def self.down
    drop_table :penalties
  end
end
