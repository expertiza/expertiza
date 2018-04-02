require 'rails_helper'

describe GithubDataController do
    context "When testing the GithubDataController" do
        let(:submission_record) {double('SubmissionRecord', id: 1, operation: 'Submit Hyperlink', content: 'https://github.com/expertiza/expertiza/pull/943', team_id: 1, assignment_id: 1)}
        let(:team) {double('Team', id: 1, submission: submission, parent_id: 1)}
        let(:assignment) {double('Assignment', id: 1, team: team, submission_record: submission_record, intstructor_id: 1, course_id: 1)}     

        before(:each) do
            allow(Submission).to receive(:find).with('1').and_return(submission)
        end

        describe 'show' do
                it "renders the #show view" do
                    get :show, id: 1
                    expect(response).to render_template(:show)
                end
        end
    end
end


