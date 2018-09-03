class CreateCourseBadges < ActiveRecord::Migration
  def change
    create_table :course_badges do |t|
      t.references :badge, index: true, foreign_key: true
      t.references :course, index: true, foreign_key: true
      t.string :award_mechanism
      t.string :manual_award_criteria
      t.timestamps null: false
    end
  end
end
