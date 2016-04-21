class RemoveReferenceBadgesBadgeUsers < ActiveRecord::Migration
  def change
    remove_reference :badge_users, :badge, index: true
  end
end
