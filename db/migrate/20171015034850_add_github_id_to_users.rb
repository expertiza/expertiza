class AddGithubIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :github_id, :string
  end
end