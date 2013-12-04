class RenameMetareviewResponseMapToMetareviewResponse < ActiveRecord::Migration
  def self.up
    rename_table :metareview_response_maps, :metareview_responses
  end

  def self.down
    rename_table :metareview_responses, :metareview_response_maps
  end
end
