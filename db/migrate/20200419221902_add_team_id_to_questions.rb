class AddTeamIdToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :team_id, :integer, :default => nil
  end
end
