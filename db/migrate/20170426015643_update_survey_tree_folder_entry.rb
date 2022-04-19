class UpdateSurveyTreeFolderEntry < ActiveRecord::Migration
  def change
    execute "UPDATE tree_folders set name = 'Assignment Survey' where name in ('Survey')"
  end
end
