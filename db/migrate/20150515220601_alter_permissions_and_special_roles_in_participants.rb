class AlterPermissionsAndSpecialRolesInParticipants < ActiveRecord::Migration[4.2]
  def self.up
    change_table :participants do |t|
      t.rename :submit_allowed, :can_submit
      t.rename :review_allowed, :can_review
      t.rename :take_quiz_allowed, :can_take_quiz
      t.rename :special_role, :duty
    end
  end

  def self.down
    change_table :participants do |t|
      t.rename :duty, :special_role
      t.rename :can_take_quiz, :take_quiz_allowed
      t.rename :can_review, :review_allowed
      t.rename :can_submit, :submit_allowed
    end
  end
end
