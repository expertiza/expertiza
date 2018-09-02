class AddExternalIdToAwardedBadges < ActiveRecord::Migration
  def change
    add_column :awarded_badges, :external_id, :integer
  end
end
