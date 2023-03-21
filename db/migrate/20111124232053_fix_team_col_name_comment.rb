class FixTeamColNameComment < ActiveRecord::Migration[4.2]
  def self.up
    rename_column :teams, :comment, :comments_for_advertisement
  end

  def self.down; end
end
