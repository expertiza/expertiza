class AddIsPublicToResponses < ActiveRecord::Migration
  def change
    add_column :responses, :is_public, :boolean
  end
end
