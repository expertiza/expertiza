class UpdateMapId < ActiveRecord::Migration
  def change
  	rename_column :review_chats, :map_id, :response_map_id
  end
end
