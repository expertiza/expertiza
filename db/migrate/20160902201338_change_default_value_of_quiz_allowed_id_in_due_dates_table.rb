class ChangeDefaultValueOfQuizAllowedIdInDueDatesTable < ActiveRecord::Migration[4.2]
  def self.up
    change_column_default :due_dates, :quiz_allowed_id, 1
  end

  def self.down
    change_column_default :due_dates, :quiz_allowed_id, nil
  end
end
