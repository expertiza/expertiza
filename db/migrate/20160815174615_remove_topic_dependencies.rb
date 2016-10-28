class RemoveTopicDependencies < ActiveRecord::Migration
  def change
    drop_table :topic_dependencies
  end
end
