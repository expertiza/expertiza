class GithubAssociation < ActiveRecord::Migration[5.1]
  def change
    create_table :github_associations do |t|
      t.string :expertiza_username
      t.string :github_user
    end
  end
end
