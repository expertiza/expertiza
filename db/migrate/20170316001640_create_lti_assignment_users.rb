class CreateLtiAssignmentUsers < ActiveRecord::Migration
  def change
    create_table :lti_assignment_users do |t|
      t.integer :user_id
      t.integer :assignment_id
      t.integer :participant_id
      t.text :lis_result_source_did
      t.integer :tenant_id
      t.string :grade

      t.timestamps null: false
    end
  end
end
