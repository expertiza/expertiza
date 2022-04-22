class MigrateWaitlistsToWaitlistTeams < ActiveRecord::Migration[5.1]
  def up
    waitlists_to_be_migrated = SignedUpTeam.where(is_waitlisted: true)
    waitlists_to_be_migrated.each do |signed_up_waitlist|
      waitlist = WaitlistTeam.new
      waitlist.team_id = signed_up_waitlist.team_id
      waitlist.topic_id = signed_up_waitlist.topic_id
      topic_entry = SignUpTopic.find_by(id: waitlist.topic_id)
      team_entry = Team.find_by(id: waitlist.team_id)
      waitlist_team_entry = WaitlistTeam.find_by(team_id: signed_up_waitlist.team_id, topic_id: signed_up_waitlist.topic_id)

      if !topic_entry.nil? && !team_entry.nil? && waitlist_team_entry.nil?
        waitlist.save
        # signed_up_waitlist.delete
      end
    end

    # remove_column :signed_up_teams, :is_waitlisted

  end
  
  def down
    # add_column :signed_up_teams, :is_waitlisted, :boolean, null: false
  end
end
