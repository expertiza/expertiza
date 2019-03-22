class AddAutoDroppedFromWaitlistToSignedUpTeams < ActiveRecord::Migration
  def change
    add_column :signed_up_teams, :auto_dropped_from_waitlist, :boolean
  end
end
