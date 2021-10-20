class DropParticipantScoreView < ActiveRecord::Migration
  def change
    execute <<-SQL
      DROP VIEW participant_score_views
    SQL
  end
end
