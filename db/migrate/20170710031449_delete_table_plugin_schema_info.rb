class DeleteTablePluginSchemaInfo < ActiveRecord::Migration[4.2]
  def change
    drop_table :plugin_schema_info
  end
end
