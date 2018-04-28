class CreateAssignmentDutyQuestionnaireMapping < ActiveRecord::Migration
  def change
    create_table :assignment_duty_questionnaire_mappings do |t|

      t.timestamps null: false
      t.integer :questionnaire_id
      t.integer :assignment_id
      t.integer :duty_id
    end
  end
end