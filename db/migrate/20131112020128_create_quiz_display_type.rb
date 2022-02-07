class CreateQuizDisplayType < ActiveRecord::Migration
  def self.up
    TreeFolder.create :name => "Quiz", :child_type => "QuestionnaireNode"
  end

  def self.down
    TreeFolder.find_by_name("Quiz").destroy
  end
end
