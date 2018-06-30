class AddAutoAwardToAssignmentBadges < ActiveRecord::Migration
  def change
    add_column :assignment_badges, :auto_award, :tinyint
  end
end
