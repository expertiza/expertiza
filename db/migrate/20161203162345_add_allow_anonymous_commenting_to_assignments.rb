class AddAllowAnonymousCommentingToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :allow_anonymous_commenting, :boolean
  end
end
