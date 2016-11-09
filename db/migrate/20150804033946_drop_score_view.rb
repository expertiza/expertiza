class DropScoreView < ActiveRecord::Migration
  def change
    execute <<-SQL
      drop view score_views;
    SQL
  end
end
