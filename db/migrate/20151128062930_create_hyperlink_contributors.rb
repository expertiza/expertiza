class CreateHyperlinkContributors < ActiveRecord::Migration
  def change
    create_table :hyperlink_contributors do |t|
      t.references :participant, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
