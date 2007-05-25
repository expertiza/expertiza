class CreateMappingStrategies < ActiveRecord::Migration
  def self.up
    create_table :mapping_strategies do |t|
      t.column :name, :string # the name of the strategy, e.g., "static", "dynamic", "self-assigned"
    end
  end

  def self.down
    drop_table :mapping_strategies
  end
end
