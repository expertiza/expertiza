class CreateQuizDeadlineType < ActiveRecord::Migration[4.2]
  def self.up
    DeadlineType.create name: 'quiz'
  end

  def self.down
    DeadlineType.find_by_name('quiz').destroy
  end
end
