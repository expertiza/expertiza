class AddIsAnonymousFieldToAssignment < ActiveRecord::Migration
  def change
    add_column :assignments, :is_anonymous, :boolean, :default => true
  end
end
