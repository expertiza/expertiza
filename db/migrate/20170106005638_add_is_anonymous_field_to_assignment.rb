class AddIsAnonymousFieldToAssignment < ActiveRecord::Migration[4.2]
  def change
    add_column :assignments, :is_anonymous, :boolean, default: true
  end
end
