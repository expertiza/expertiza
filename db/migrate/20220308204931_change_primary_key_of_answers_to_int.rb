class ChangePrimaryKeyOfAnswersToInt < ActiveRecord::Migration[5.1]
  def change
    change_column :answers, :id, :integer
  end
end
