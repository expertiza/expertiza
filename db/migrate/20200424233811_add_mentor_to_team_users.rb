class AddMentorToTeamUsers < ActiveRecord::Migration
  def change
	add_column :teams_users, :is_mentor, :boolean
  end
end
