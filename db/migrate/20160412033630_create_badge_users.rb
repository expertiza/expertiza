class CreateBadgeUsers < ActiveRecord::Migration
  def change
    create_table :badge_users do |t|
      t.column "is_course_badge", :boolean, :default => false, :null => false
    end

    add_reference :badge_users, :badge, references: :badges, index: true
    add_foreign_key :badge_users, :badges, column: :badge_id

    add_reference :badge_users, :user, references: :users, index: true
    add_foreign_key :badge_users, :users, column: :user_id

    add_reference :badge_users, :assignment, references: :assignments, index: true
    add_foreign_key :badge_users, :assignments, column: :assignment_id

    add_reference :badge_users, :course, references: :courses, index: true
    add_foreign_key :badge_users, :courses, column: :course_id

  end
end
