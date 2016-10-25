class ChangeInstitutionsIdToInstituteId < ActiveRecord::Migration
  def change
    rename_column :users, :institutions_id, :institution_id
  end
end
