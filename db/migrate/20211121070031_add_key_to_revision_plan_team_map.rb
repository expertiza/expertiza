class AddKeyToRevisionPlanTeamMap < ActiveRecord::Migration
  def change
    add_reference :revision_plan_team_maps, :questionnaire, index: true, foreign_key: true
  end
end
