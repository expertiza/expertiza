class ChangeResponseMaps < ActiveRecord::Migration
  def change
  	remove_column :response_maps, :reviewer_id
	change_table :response_maps do |t|
		t.references :reviewer, polymorphic: true
	end
  end
end
