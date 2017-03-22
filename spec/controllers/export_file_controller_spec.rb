require 'rails_helper'

describe ExportFileController do
  describe "check export to detailed csv" do
    assignment = create(:assignment)
    create(:assignment_team, name: "team1")
    student = create(:student, name: "student1")
    create(:participant, user: student)
    create(:questionnaire)
    create(:question)
    create(:review_response_map)
    create(:response)
    create(:answer, comments: "Test comment")
    expected_csv = File.read('spec/features/assignment_export_details/expected_details_csv.txt')
    generated_csv = post :exportdetails, id: assignment.id, delim_type2: ",", model: "Assignment"
    expect(generated_csv).to eq(expected_csv)
  end
end