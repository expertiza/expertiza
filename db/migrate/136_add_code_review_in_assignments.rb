class AddCodeReviewInAssignments < ActiveRecord::Migration
  def self.up
    add_column :assignments, :codereview, :boolean
  end

  def self.down
  end
end