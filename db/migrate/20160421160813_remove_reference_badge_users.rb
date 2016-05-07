class RemoveReferenceBadgeUsers < ActiveRecord::Migration
  def change
    remove_foreign_key :badge_users, :column => :badge_id
  end
end
