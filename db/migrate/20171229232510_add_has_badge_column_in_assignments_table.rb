# frozen_string_literal: true

class AddHasBadgeColumnInAssignmentsTable < ActiveRecord::Migration[4.2]
  def change
    add_column :assignments, :has_badge, :boolean
  end
end
