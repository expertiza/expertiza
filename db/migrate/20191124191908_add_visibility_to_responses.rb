class AddVisibilityToResponses < ActiveRecord::Migration
  def change
    add_column :responses, :visibility, :integer
  end
end
