class AddUsedInRoundToAssignmentQuestionnaires < ActiveRecord::Migration
  def self.up
    add_column "assignment_questionnaires","used_in_round",:integer

  end

  def self.down
    remove_column "assignment_questionnaires","used_in_round"
  end
end