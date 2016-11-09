class CreateTopicDependencies < ActiveRecord::Migration
  def self.up
    create_table :topic_dependencies do |t|
      t.column :topic_id, :integer, :null => false
      t.column :dependent_on, :string, :null => false        
    end
  end

  def self.down
    drop_table :topic_dependencies
  end
end
