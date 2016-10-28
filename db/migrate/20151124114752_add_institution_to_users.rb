class AddInstitutionToUsers < ActiveRecord::Migration
  def change
    add_column :users, :institutions_id, :integer
  end
end
