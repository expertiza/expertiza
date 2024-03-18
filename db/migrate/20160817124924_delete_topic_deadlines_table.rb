class DeleteTopicDeadlinesTable < ActiveRecord::Migration[4.2]
  def self.up
    drop_table :topic_deadlines
  end

  def self.down
    create_table :topic_deadlines do |t|
      t.datetime :due_at
      t.integer :deadline_type_id
      t.integer :topic_id
      t.integer :late_policy_id
      t.integer :submission_allowed_id
      t.integer :review_allowed_id
      t.integer :review_of_review_allowed_id
      t.integer :round
    end

    add_index 'topic_deadlines', ['deadline_type_id'], name: 'fk_deadline_type_topic_deadlines', using: :btree
    add_index 'topic_deadlines', ['late_policy_id'], name: 'fk_topic_deadlines_late_policies', using: :btree
    add_index 'topic_deadlines', ['review_allowed_id'], name: 'idx_review_allowed', using: :btree
    add_index 'topic_deadlines', ['review_of_review_allowed_id'], name: 'idx_review_of_review_allowed', using: :btree
    add_index 'topic_deadlines', ['submission_allowed_id'], name: 'idx_submission_allowed', using: :btree
    add_index 'topic_deadlines', ['topic_id'], name: 'fk_topic_deadlines_topics', using: :btree

    add_foreign_key 'topic_deadlines', 'deadline_types', name: 'fk_topic_deadlines_deadline_type'
    add_foreign_key 'topic_deadlines', 'late_policies', name: 'fk_topic_deadlines_late_policies'
    add_foreign_key 'topic_deadlines', 'sign_up_topics', column: 'topic_id', name: 'fk_topic_deadlines_sign_up_topic'
  end
end
