class CreateBadges < ActiveRecord::Migration
  def change
    create_table :badges do |t|
      t.string :name
      t.string :description

      t.timestamps null: false
    end
    Badge.create name: 'Good Reviewer',
                 description: 'This badge is awarded to students who receive very high review grades.'
    Badge.create name: 'Good Teammate',
                 description: 'This badge is awarded to students who receive very high teammate review scores.'
  end
end
