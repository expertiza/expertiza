class AddTeamIdToSubmissionHistory < ActiveRecord::Migration
  def self.up
    add_column :submission_histories, :team_id, :integer
  end

  def self.down
  end
end
