class AddVisibilityToResponse < ActiveRecord::Migration[4.2]
  def change
    add_column :responses, :visibility, :string, default: 'private'
  end
end
