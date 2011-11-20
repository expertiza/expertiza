class CreateQuizDisplayType < ActiveRecord::Migration
  def self.up
    TreeFolder.create :name => "Quiz", :child_type => "QuestionnaireNode", :parent_id => 1
  end

  def self.down
    TreeFolder.find_by_name("Quiz").destroy
  end
end
