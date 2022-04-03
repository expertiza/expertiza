class RemoveTopicDependencies < ActiveRecord::Migration[4.2]
  def change
    drop_table :topic_dependencies
  end
end
