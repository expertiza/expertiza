class CreateChats < ActiveRecord::Migration
  def change
    create_table :chats do |t|

      t.integer :review_response_map_id, :null => false,:references=>[:response_maps, :id]

      t.timestamps null: false

    end
  end
end
