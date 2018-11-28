class ChangeGradingHistoryTypeName < ActiveRecord::Migration
  def change
    rename_column :grading_histories, :type, :grading_type
  end
end
