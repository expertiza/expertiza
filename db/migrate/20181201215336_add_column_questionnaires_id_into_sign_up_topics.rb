class AddColumnQuestionnairesIdIntoSignUpTopics < ActiveRecord::Migration
  def up
    add_column :sign_up_topics, :questionnaire_id, :integer
  end
end
