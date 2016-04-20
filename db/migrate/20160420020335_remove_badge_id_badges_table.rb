class RemoveBadgeIdBadgesTable < ActiveRecord::Migration
  def change
    remove_column :badges, :badge_id
  end
end
