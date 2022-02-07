class DeleteTablePluginSchemaInfo < ActiveRecord::Migration
  def change
  	drop_table :plugin_schema_info
  end
end
