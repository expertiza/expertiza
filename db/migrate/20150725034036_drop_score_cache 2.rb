class DropScoreCache < ActiveRecord::Migration
  def change
    drop_table :score_caches
  end
end
