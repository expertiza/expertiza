class RemoveDefaultChoicesFromQuestionnaires < ActiveRecord::Migration
  def change
    remove_column "questionnaires","default_num_choices"
  end
end
