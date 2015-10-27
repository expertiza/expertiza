require 'rails_helper'

describe TreeDisplayController do¬
  describe "#filter" do
    before(:each) do
      @course = Course.new({
                            "id" => "1",
                            "name" => "My course"
                          })
      @assignment = Assignment.new({
                                    "id" => "101",
                                    "name" =>"My assignment"
                                  })
      @questionnaire = Questionnaire.new({
                                          "id" => "1001",
                                          "name" => "My Questionnaire"
                                        })
      @assignment_questionnaire = AssignmentQuestionnaire.new({
                                                    "id" => "10001",
                                                    "assignment_id" => "101",
                                                    "questionnaire_id" => "1001"
                                                  })
    end
    it "filters questionnaire by assignment name" do
      TreeDisplayController.new.send(:filter,{:filter_string => "My assignment", :filternode=>"QAN"}).should == "filter+1001"
    end
    it "filters assignment by course name" do
      TreeDisplayController.new.should_receive(:filter).with("My course", "ACN").and_return("filter+My course")
    end
  end
end

