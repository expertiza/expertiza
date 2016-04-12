class CreateAssignmentGroups < ActiveRecord::Migration
  def change
    create_table :assignment_groups do |t|
    end

    add_reference :assignment_groups, :badge_group, references: :badge_groups, index: true
    add_foreign_key :assignment_groups, :badge_groups, column: :badge_group_id

    add_reference :assignment_groups, :assignment, references: :assignments, index: true
    add_foreign_key :assignment_groups, :assignments, column: :assignment_id

  end
end
