class AddVaryByTopicToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :vary_by_topic, :boolean, default: false
  end
end
