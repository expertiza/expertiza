require 'rails_helper'

RSpec.describe GithubMetric, type: :model do
  let(:participant) { build_stubbed(:participant) }
  let(:assignment) { build_stubbed(:assignment, id: 1, participants: [participant]) }
  let(:team) { build_stubbed(:assignment_team, id: 1, assignment: assignment, users: [participant.user]) }
  let(:github_metric) { build(:github_metric, participant_id: participant.id, assignment_id: assignment.id, token: "mockToken") }

  before do
    allow(AssignmentParticipant).to receive(:find).and_return(participant)
    allow(Assignment).to receive(:find).and_return(assignment)
    allow(participant).to receive(:team).and_return(team)
  end

  # Test to see that the GithubMetrics object is properly initialized
  describe '#initialize' do
    it 'initializes with correct attributes' do
      expect(github_metric.participant).to eq(participant)
      expect(github_metric.assignment).to eq(assignment)
      expect(github_metric.team).to eq(team)
      expect(github_metric.token).to eq("mockToken")
    end
  end

  # Test to see that the appropriate error is given if there is no github access token
  describe '#process_metrics' do
    context 'when token is missing' do
      it 'raises a missing token error' do
        github_metric.instance_variable_set(:@token, nil)
        expect { github_metric.process_metrics }.to raise_error(StandardError, 'GitHub access token is required')
      end
    end

    # Test to see that the appropriate error is given if no pull request links have been submitted
    context 'when no pull request links exist' do
      it 'raises an error for missing pull request links' do
        allow(team).to receive(:hyperlinks).and_return([])
        expect { github_metric.process_metrics }.to raise_error(StandardError, 'No pull request links have been submitted by this team.')
      end
    end

    context 'when pull request links exist' do
      let(:pull_request_url) { "https://github.com/owner/repo/pull/123" }

      before do
        allow(team).to receive(:hyperlinks).and_return([pull_request_url])
        allow(github_metric).to receive(:retrieve_pull_request_metrics).and_return({
          "data" => {
            "repository" => {
              "pullRequest" => {
                "number" => 123,
                "additions" => 10,
                "deletions" => 5,
                "changedFiles" => 2,
                "merged" => true,
                "mergeable" => "MERGED",
                "headRefOid" => "abc123",
                "commits" => {
                  "totalCount" => 3,
                  "pageInfo" => { "hasNextPage" => false, "endCursor" => nil },
                  "edges" => []
                }
              }
            }
          }
        })
      end

      # Test to see that given a valid pull request link exists that the
      # metrics are properly parsed from a returned graphql query
      it 'retrieves and parses pull request metrics successfully' do
        github_metric.process_metrics
        expect(github_metric.total_additions).to eq(10)
        expect(github_metric.total_deletions).to eq(5)
        expect(github_metric.total_files_changed).to eq(2)
        expect(github_metric.total_commits).to eq(3)
        expect(github_metric.merge_status).to eq({ 123 => "MERGED" })
      end
    end
  end

  describe '#pull_query' do
    let(:hyperlink_data) do
      {
        "owner_name" => "owner",
        "repository_name" => "repo",
        "pull_request_number" => "123"
      }
    end

    # Test to see that a proper graphql query is formed when given valid parameters
    it 'formats the pull query correctly' do
      query = github_metric.pull_query(hyperlink_data)
      expect(query).to include("repository(owner: \"owner\", name: \"repo\")")
      expect(query).to include("pullRequest(number: 123)")
    end
  end
end
