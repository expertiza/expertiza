class CreateBadgeAwardingRules < ActiveRecord::Migration
  def change
    create_table :badge_awarding_rules do |t|
      t.references :badge, index: true, foreign_key: true
      t.references :assignment, index: true, foreign_key: true
      t.references :question, index: true, foreign_key: true
      t.string :operator
      t.integer :threshold
      t.string :logic_operator, default: "AND"
      t.timestamps null: false
    end
  end
end
