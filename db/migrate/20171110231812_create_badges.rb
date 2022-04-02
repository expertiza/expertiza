class CreateBadges < ActiveRecord::Migration[4.2]
  def change
    create_table :badges do |t|
      t.string :name
      t.string :description
      t.string :image_name
      t.timestamps null: false
    end

    Badge.create name: 'Good Reviewer',
                 description: 'This badge is awarded to students who receive very high review grades.',
                 image_name: 'good-reviewer.png'
    Badge.create name: 'Good Teammate',
                 description: 'This badge is awarded to students who receive very high teammate review scores.',
                 image_name: 'good-teammate.png'
  end
end
