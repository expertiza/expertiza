class RemoveDefaultChoicesFromQuestionnaires < ActiveRecord::Migration[4.2]
  def change
    remove_column 'questionnaires', 'default_num_choices'
  end
end
