class AddReferenceBadgeIdBadgeUsers < ActiveRecord::Migration
  def change
    add_reference :badge_users, :badge, references: :badges, index: true
    add_foreign_key :badge_users, :badges, column: :badge_id
  end
end
