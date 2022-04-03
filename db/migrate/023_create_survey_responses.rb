class CreateSurveyResponses < ActiveRecord::Migration[4.2]
  def self.up
    create_table 'survey_responses', force: true do |t|
      t.column 'score', :integer, limit: 8
      t.column 'comments', :text
      t.column 'assignment_id', :integer, limit: 8, default: 0, null: false
      t.column 'question_id', :integer, limit: 8, default: 0, null: false
      t.column 'survey_id', :integer, limit: 8, default: 0, null: false
      t.column 'email', :string
    end

    add_index 'survey_responses', ['assignment_id'], name: 'fk_survey_assignments'

    add_index 'survey_responses', ['question_id'], name: 'fk_survey_questions'

    add_index 'survey_responses', ['survey_id'], name: 'fk_survey_questionnaires'
  end

  def self.down
    drop_table 'survey_responses'
  end
end
