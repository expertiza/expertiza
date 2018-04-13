require 'rails_helper'

describe GithubDataController do
    context "When testing the GithubDatumModel" do
        let(:submission_record) {double('SubmissionRecord', id: 1, operation: 'Submit Hyperlink', content: 'https://github.com/expertiza/expertiza/pull/943', team_id: 1, assignment_id: 1)}
        let(:team) {double('Team', id: 1, submission: submission, parent_id: 1)}
        let(:assignment) {double('Assignment', id: 1, team: team, submission_record: submission_record, intstructor_id: 1, course_id: 1)}     

        before(:each) do
            allow(Submission).to receive(:find).with('1').and_return(submission)
        end

        describe 'retrieve_github_url' do
            context "when a submission record have already existed" do
                it "should return corresponding owner, repo, and pull number of a submission record" do
                    allow(GITHUB_PULL_REGEX).to receive(:match).with(submission.content).and_return(matches)
                    expect(matches).to eq ['expertiza', 'expertiza', '943']
                end
            end
        end

       describe 'retrieve_graphql_data' do
           context "when we know which pull request we want to extract from github" do
                it "should build up the commits array" do
                    allow(self).to receive(:query).with('IndexQuery', 'expertiza', 'expertiza', '943').and_return(data)    
                    allow(data).to receive_message_chain(:repository, :pull_request, :commits).with().and_yield(github_commits)
                    allow(Array).to receive(:new).with().and_return(@commits)
                    allow(github_commits).to receive(:nodes).with().and_return(nodes)
                    nodes.each do |node|
                        allow(node).to receive_message_chain(:commit, :message, :start_with?).with().with().with('Merge').and_yield(merge_or_not)
                        next if merge_or_not
                        allow(GithubDatum).to receive_message_chain(:where, :first).with(node.commit.oid).with().and_yeild(commit)
                        allow(commit).to receive(:nil?).with().and_return(nil_or_not)
                        allow(GithubDatum).to receive(:create).with(submission, node.commit.oid, node.commit.committer.name, node.commit.additions, node.commit.deletions, node.commit.changed_files, DateTime.parse(node.commit.committed_date)).and_return(commit) if nil_or_not
                        allow(@commits).to receive(:push).with(commit).and_return()
                    end
                    expect(@commits.length).to_not eq 0
                end
           end
       end
    end
end



