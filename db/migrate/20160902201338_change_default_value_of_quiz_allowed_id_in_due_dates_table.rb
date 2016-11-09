class ChangeDefaultValueOfQuizAllowedIdInDueDatesTable < ActiveRecord::Migration
  def self.up
  	change_column_default :due_dates, :quiz_allowed_id, 1
  end

  def self.down
  	change_column_default :due_dates, :quiz_allowed_id, nil
  end
end
