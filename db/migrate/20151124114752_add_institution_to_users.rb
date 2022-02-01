class AddInstitutionToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :institutions_id, :integer
  end
end
