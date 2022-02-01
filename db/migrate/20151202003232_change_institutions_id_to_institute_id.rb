class ChangeInstitutionsIdToInstituteId < ActiveRecord::Migration[4.2]
  def change
    rename_column :users, :institutions_id, :institution_id
  end
end
