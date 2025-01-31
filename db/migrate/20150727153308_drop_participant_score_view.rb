class DropParticipantScoreView < ActiveRecord::Migration[4.2]
  def change
    execute <<-SQL
      DROP VIEW participant_score_views
    SQL
  end
end
