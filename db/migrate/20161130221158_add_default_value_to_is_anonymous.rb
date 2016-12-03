class AddDefaultValueToIsAnonymous < ActiveRecord::Migration
  def change
    change_column :assignments, :isAnonymous, :boolean, :default => true
  end
end
