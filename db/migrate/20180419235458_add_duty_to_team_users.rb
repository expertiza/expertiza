class AddDutyToTeamUsers < ActiveRecord::Migration
  def change
  	add_reference :teams_users , :duties , index: true
  end
end
