class AddEndToResponsetimes < ActiveRecord::Migration
  def change
    add_column :responsetimes, :end, :datetime
  end
end
