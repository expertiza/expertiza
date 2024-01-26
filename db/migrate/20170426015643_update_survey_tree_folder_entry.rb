class UpdateSurveyTreeFolderEntry < ActiveRecord::Migration[4.2]
  def change
    execute "UPDATE tree_folders set name = 'Assignment Survey' where name in ('Survey')"
  end
end
