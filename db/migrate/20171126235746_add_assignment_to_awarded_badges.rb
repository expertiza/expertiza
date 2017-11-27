class AddAssignmentToAwardedBadges < ActiveRecord::Migration
  def change
    add_reference :awarded_badges, :assignment, index: true, foreign_key: true
  end
end
	