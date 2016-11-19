class AddDutyToTeamsUsers < ActiveRecord::Migration
  def change
    add_column :teams_users, :duty, :string
  end
end
