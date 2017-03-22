require 'rails_helper'

describe ExportFileController do
  describe "check export to detailed csv", type: :controller do
    it "checks if returned csv is same as expected" do
      assignment = create(:assignment)
      create(:assignment_team, name: "team1")
      student = create(:student, name: "student1")
      create(:participant, user: student)
      create(:questionnaire)
      create(:question)
      create(:review_response_map)
      create(:response)
      create(:answer, comments: "Test comment")
      options = {"team_id"=>"true", "team_name"=>"true",
                 "reviewer"=>"true", "question"=>"true",
                 "question_id"=>"true", "comment_id"=>"true",
                 "comments"=>"true", "score"=>"true"}
      expected_csv = File.read('spec/features/assignment_export_details/expected_details_csv.txt')
      # generated_csv = post :exportdetails, id: assignment.id, delim_type2: ",", model: "Assignment", details: options
      # expect(generated_csv).to eq(expected_csv)
      controller.params = {
          id: assignment.id,
          delim_type2: ",",
          model: 'Assignment',
          details: options
      }
      generated_csv = controller.send(:exportdetails, controller.params)
      expect (generated_csv).to eq(expected_csv)
    end
  end
end