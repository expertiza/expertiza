class CopyFromTeamToSubmissionHistory < ActiveRecord::Migration
  def change
  end
  def up
    Team.for_each do |t|
      SubmissionHistory.create()
      sh.team_id
    end
  end
  def down

  end
end
