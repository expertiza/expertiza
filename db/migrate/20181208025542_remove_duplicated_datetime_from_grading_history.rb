class RemoveDuplicatedDatetimeFromGradingHistory < ActiveRecord::Migration
  def up
    remove_column :grading_histories, :graded_at
  end

  def down
    add_column :grading_histories, :graded_at, :datetime
  end
end
