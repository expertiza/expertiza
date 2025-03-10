class AddVaryByTopicToAssignments < ActiveRecord::Migration[4.2]
  def change
    add_column :assignments, :vary_by_topic?, :boolean, default: false
  end
end
