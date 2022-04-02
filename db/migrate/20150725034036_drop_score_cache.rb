class DropScoreCache < ActiveRecord::Migration[4.2]
  def change
    drop_table :score_caches
  end
end
