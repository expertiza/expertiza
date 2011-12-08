class AddStudentQuizController < ActiveRecord::Migration
  def self.up
    permission = Permission.find_by_name('do assignments')
    controller = SiteController.find_or_create_by_name('student_quiz')
    controller.permission_id = permission.id
    controller.save
  end

  def self.down
  end
end
