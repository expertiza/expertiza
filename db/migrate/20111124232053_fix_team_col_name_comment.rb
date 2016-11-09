class FixTeamColNameComment < ActiveRecord::Migration
  def self.up
    rename_column :teams, :comment, :comments_for_advertisement
  end

  def self.down
  end
end
