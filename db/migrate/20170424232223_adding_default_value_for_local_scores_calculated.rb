class AddingDefaultValueForLocalScoresCalculated < ActiveRecord::Migration
  def change
    change_column :assignments, :local_scores_calculated, :boolean, :default => false
  end
end
