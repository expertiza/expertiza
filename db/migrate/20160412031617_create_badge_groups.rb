class CreateBadgeGroups < ActiveRecord::Migration
  def change
    create_table :badge_groups do |t|
      t.column "strategy", :string, :default => "", :null => false
      t.column "threshold", :integer, :null => false
    end
  end
end
