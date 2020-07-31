class AddVisibilityToResponse < ActiveRecord::Migration
  def change
    add_column :responses, :visibility, :string, default: "private" 
  end
end
