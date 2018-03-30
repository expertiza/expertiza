require 'rails_helper'

describe GithubDataController do
    context "When testing the GithubDataController" do
        let(:submission_record) {double('SubmissionRecord', id: 1, operation: 'Submit Hyperlink', content: 'https://github.com/expertiza/expertiza/pull/943', team_id: 1, assignment_id: 1)}
        let(:team) {double('Team', id: 1, submission: submission, parent_id: 1)}
        let(:assignment) {double('Assignment', id: 1, team: team, submission_record: submission_record, intstructor_id: 1, course_id: 1)}     



        before(:each) do
            allow(Submission).to receive(:find).with('1').and_return(submission)
        end

        describe 'retrieve_github_url' do
            context "when a submission record have already existed" do
                it "should return corresponding owner, repo, and pull number of a submission record" do
                    allow(Assignment).to receive_message_chain(:where, :first)
                        .with(assignment_id: '1', team_id: 1, operation: 'Submit Hyperlink', content: 'https://github.com/expertiza/expertiza/pull/943').with(no_args).and_return(submission_record)
                    post :retrieve_github_url, params: {submission_record: submission_record} 
                    expect(response).to eq ['expertiza', 'expertiza', '943']
                end
            end
        end

       describe 'retrieve_graphql_data' do
           context "when we know which pull request we want to extract from github"
                it "should build up the commits, commits by user, and changes by date array"
                    post :retrieve_graphql_data, params: {owner: expertiza, repo: expertiza, pull: 943}
                    expect(@commits.length).to_not eq 0
                    expect(@commits_by_user.length).to_not eq 0
                    expect(@changes_by_date.length).to_not eq 0
       end
    end
end


