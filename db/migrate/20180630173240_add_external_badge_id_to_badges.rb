class AddExternalBadgeIdToBadges < ActiveRecord::Migration
  def change
    add_column :badges, :external_badge_id, :integer
  end
end
