class AddSupplementaryRubricToTeams < ActiveRecord::Migration
  def change
    add_column :teams, :supplementary_rubric, :integer
  end
end
