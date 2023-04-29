# frozen_string_literal: true
describe MetricsController do
  let(:review_response) { build(:response) }
  let(:assignment) { build(:assignment, id: 1, max_team_size: 2, questionnaires: [review_questionnaire], is_penalty_calculated: true)}
  let(:assignment_questionnaire) { build(:assignment_questionnaire, used_in_round: 1, assignment: assignment) }
  let(:participant) { build(:participant, id: 1, assignment: assignment, user_id: 1) }
  let(:participant2) { build(:participant, id: 2, assignment: assignment, user_id: 1) }
  let(:review_questionnaire) { build(:questionnaire, id: 1, questions: [question]) }
  let(:admin) { build(:admin) }
  let(:instructor) { build(:instructor, id: 6) }
  let(:question) { build(:question) }
  let(:team) { build(:assignment_team, id: 1, assignment: assignment, users: [instructor]) }
  let(:student) { build(:student) }
  let(:review_response_map) { build(:review_response_map, id: 1) }
  let(:assignment_due_date) { build(:assignment_due_date) }
  let(:ta) { build(:teaching_assistant, id: 8) }

  describe '#get_statuses_for_pull_request' do
    before(:each) do
      allow(Net::HTTP).to receive(:get) { "{\"team\":\"rails\", \"players\":\"36\"}" }
    end

    it 'makes a call to the GitHub API to get status of the head commit passed' do
      expect(controller.query_pull_request_status({
                                                    owner: 'expertiza',
                                                    repository: 'expertiza',
                                                    head_commit: 'qwerty123'})).to eq("team" => "rails", "players" => "36")
    end
  end

  describe '#retrieve_pull_request_data' do
    before(:each) do
      controller.instance_variable_set(:@head_refs, {})
      allow(controller).to receive(:pull_request_data).and_return({ "data" => {
        "repository" => {
          "pullRequest" => {
            "headRefOid" => "qwerty123"
          }
        }
      }})
      allow(controller).to receive(:parse_pull_request_data)
    end

    it 'gets pull request details for each PR link submitted' do
      expect(controller).to receive(:pull_request_data).with("pull_request_number" => "1261",
                                                             "repository_name" => "expertiza",
                                                             "owner_name" => "expertiza")
      expect(controller).to receive(:pull_request_data).with("pull_request_number" => "1293",
                                                             "repository_name" => "mamaMiya",
                                                             "owner_name" => "Shantanu")
      controller.query_all_pull_requests(["https://github.com/expertiza/expertiza/pull/1261",
                                          "https://github.com/Shantanu/mamaMiya/pull/1293"])
    end

    it 'calls parse_github_data_pull on each of the PR details' do
      expect(controller).to receive(:parse_pull_request_data).with({ "data" => {
        "repository" => {
          "pullRequest" => {
            "headRefOid" => "qwerty123"
          }
        }
      }}).twice
      controller.query_all_pull_requests(["https://github.com/expertiza/expertiza/pull/1261",
                                          "https://github.com/Shantanu/mamaMiya/pull/1293"])
    end
  end

  # This test is XDESCRIBED because Github will invalidate and ban any secret token that gets pushed in a commit.
  # To run this test, using your own valid token, update the github access token on line 75 below with a valid token,
  # and run the test locally. Do not push with a valid token unless you are happy with the token being banned, and needing
  # to obtain a new token from the Github omniauth API.
  xdescribe '#retrieve_repository_data' do
    before(:each) do
      assignment_mock = double
      allow(assignment_mock).to receive(:created_at).and_return(DateTime.new(2021,1,1,0,0,0))
      allow(controller).to receive(:parse_repository_data)
      controller.instance_variable_set(:@assignment, assignment_mock)
      session["github_access_token"]="47a9e77a0b7067aa22d5aac868dc69a73482ff0b"
    end

    it 'gets details for each repo link submitted, excluding those for expertiza and servo' do
      expect(controller).to receive(:parse_repository_data).with({"data"=>{"repository"=>{"ref"=>{"target"=>
                                                                                                    {"id"=>"MDY6Q29tbWl0MzYyODYzODU5OjFkZjcxZDEzMTBlMTc5YmU4OTM4ZjhjOTY4ODI1NTQwYmM3ZGFjNmE=", "history"=>
                                                                                                      {"edges"=>[{"node"=>{"id"=>"MDY6Q29tbWl0MzYyODYzODU5OjFkZjcxZDEzMTBlMTc5YmU4OTM4ZjhjOTY4ODI1NTQwYmM3ZGFjNmE=", "author"=>
                                                                                                        {"name"=>"Stevan Michael Dupor", "email"=>"70522325+smdupor@users.noreply.github.com", "date"=>"2021-04-29T11:36:38-04:00"}}},
                                                                                                                 {"node"=>{"id"=>"MDY6Q29tbWl0MzYyODYzODU5OjMzZmMzZjA2YTU5ODZhNzFmNWVkNmQ3MTJlMWMzMTgyYTliYjQ4YzA=", "author"=>
                                                                                                                   {"name"=>"Stevan Michael Dupor", "email"=>"70522325+smdupor@users.noreply.github.com", "date"=>"2021-04-29T11:30:18-04:00"}}}],
                                                                                                       "pageInfo"=>{"endCursor"=>"1df71d1310e179be8938f8c968825540bc7dac6a 1", "hasNextPage"=>false}}}}}}}
      )
      controller.retrieve_repository_data(["https://github.com/smdupor/GITHUB_LANDING_TEST", "https://github.com/smdupor/GITHUB_LANDING_TEST.git"])
    end
  end

  describe '#retrieve_github_data' do
    before(:each) do
      allow(controller).to receive(:query_all_pull_requests)
      allow(controller).to receive(:retrieve_repository_data)
    end

    context 'when pull request links have been submitted' do
      before(:each) do
        teams_mock = double
        allow(teams_mock).to receive(:hyperlinks).and_return(["https://github.com/Shantanu/website",
                                                              "https://github.com/Shantanu/website/pull/1123"])
        controller.instance_variable_set(:@team, teams_mock)
      end

      it 'retrieves PR data only' do
        expect(controller).to receive(:query_all_pull_requests).with(["https://github.com/Shantanu/website/pull/1123"])
        controller.retrieve_github_data
      end
    end

    context 'when pull request links have not been submitted' do
      before(:each) do
        teams_mock = double
        allow(teams_mock).to receive(:hyperlinks).and_return(["https://github.com/Shantanu/website",
                                                              "https://github.com/expertiza/expertiza"])
        controller.instance_variable_set(:@team, teams_mock)
      end

      it 'retrieves repo details ' do
        expect(controller).to receive(:retrieve_repository_data).with(["https://github.com/Shantanu/website",
                                                                       "https://github.com/expertiza/expertiza"])
        controller.retrieve_github_data
      end
    end
  end

  describe '#retrieve_check_run_statuses' do
    before(:each) do
      allow(controller).to receive(:query_pull_request_status).and_return("check_status")
      controller.instance_variable_set(:@head_refs, "1234" => "qwerty", "5678" => "asdfg")
      controller.instance_variable_set(:@check_statuses, {})
    end

    it 'gets and stores the statuses associated with head commits of PRs' do
      expect(controller).to receive(:query_pull_request_status).with("qwerty")
      expect(controller).to receive(:query_pull_request_status).with("asdfg")
      controller.query_all_merge_statuses
      expect(controller.instance_variable_get(:@check_statuses)).to eq("1234" => "check_status",
                                                                       "5678" => "check_status")
    end
  end

  describe '#show' do
    context 'when user hasn\'t logged in to GitHub' do
      before(:each) do
        params = {id: 900}
        allow(controller).to receive(:authorize_github)
        allow(controller).to receive(:github_metrics_for_submission)
        allow(controller).to receive(:show)
        session["github_access_token"] = nil
      end

      it 'redirects user to GitHub authorization page' do
        params = {id: 900}
        get :show, params
        expect(response.status).to eq(302) #redirected
      end
    end
  end

  ###### Are we not testing an outgoing command message here to the METRICS model? Do we need to do that here or elsewhere?
  # X-describing for now
  describe '#get_github_repository_details' do
    before(:each) do
      assignment_mock = double
      allow(assignment_mock).to receive(:created_at).and_return(DateTime.new(2021,1,1,0,0,0))
      allow(controller).to receive(:parse_repository_data)
      controller.instance_variable_set(:@assignment, assignment_mock)
      allow(controller).to receive(:query_commit_statistics).and_return("github": "github")
    end

    it 'gets  make_github_graphql_request with query for repository' do
      hyperlink_data = {
        "owner_name" => "Shantanu",
        "repository_name" => "expertiza"
      }

      expect(controller).to receive(:query_commit_statistics).with(
        query:       "query {
        repository(owner: \"" + hyperlink_data["owner_name"] + "\", name: \"" + hyperlink_data["repository_name"] + "\") {
          ref(qualifiedName: \"master\") {
            target {
              ... on Commit {
                id
                  history( since:\"2021-01-01T00:00:00\") {
                    edges {
                      node {
                        id author {
                          name email date
                        }
                      }
                    }
                  pageInfo {
                    endCursor
                    hasNextPage
                  }
                }
              }
            }
          }
        }
      }"
      )

      details = controller.retrieve_repository_data(["https://github.com/Shantanu/expertiza/"])
      expect(details).to eq(["https://github.com/Shantanu/expertiza/"])
    end
  end

  describe '#get_pull_request_details' do
    before(:each) do
      allow(controller).to receive(:get_query)
      allow(controller).to receive(:query_commit_statistics).and_return(
        "data" => {
          "repository" => {
            "pullRequest" => {
              "commits" => {
                "edges" => [],
                "pageInfo" => {
                  "hasNextPage" => false,
                  "endCursor" => "qwerty"
                }
              }
            }
          }
        }
      )
    end

    it 'gets pull request data for link passed' do
      hyperlink_data = {};
      hyperlink_data["pull_request_number"] = "1917";
      hyperlink_data["repository_name"] = "expertiza";
      hyperlink_data["owner_name"] = "expertiza";
      data = controller.pull_request_data(hyperlink_data)
      expect(data).to eq(
                        "data" => {
                          "repository" => {
                            "pullRequest" => {
                              "commits" => {
                                "edges" => [],
                                "pageInfo" => {
                                  "hasNextPage" => false,
                                  "endCursor" => "qwerty"
                                }
                              }
                            }
                          }
                        }
                      )
    end
  end

  describe '#process_github_authors_and_dates' do
    before(:each) do
      controller.instance_variable_set(:@authors, {})
      controller.instance_variable_set(:@dates, {})
      controller.instance_variable_set(:@parsed_data, {})
    end
    it 'sets authors and data for GitHub data' do
      controller.count_github_authors_and_dates("author", "email@ncsu.edu", "date")
      expect(controller.instance_variable_get(:@authors)).to eq("author" => "email@ncsu.edu")
      expect(controller.instance_variable_get(:@dates)).to eq("date" => 1)
      expect(controller.instance_variable_get(:@parsed_data)).to eq("author" => {"date" => 1})

      controller.count_github_authors_and_dates("author", "email@ncsu.edu", "date")
      expect(controller.instance_variable_get(:@parsed_data)).to eq("author" => {"date" => 2})
    end
  end

  describe '#parse_github_pull_request_data' do
    before(:each) do
      allow(controller).to receive(:count_github_authors_and_dates)
      allow(controller).to receive(:team_statistics)
      allow(controller).to receive(:sort_commit_dates)
      @github_data = {
        "data" => {
          "repository" => {
            "pullRequest" => {
              "commits" => {
                "edges" => [
                  {
                    "node" => {
                      "commit" => {
                        "author" => {
                          "name" => "Shantanu",
                          "email" => "shantanu@ncsu.edu"
                        },
                        "committedDate" => "2018-12-1013:45"
                      }
                    }
                  }
                ]
              }
            }
          }
        }
      }
    end

    it 'calls team_statistics' do
      expect(controller).to receive(:team_statistics).with(@github_data, :pull)
      controller.parse_pull_request_data(@github_data)
    end

    it 'calls process_github_authors_and_dates for each commit object of GitHub data passed in' do
      expect(controller).to receive(:count_github_authors_and_dates).with("Shantanu", "shantanu@ncsu.edu", "2018-12-10")
      controller.parse_pull_request_data(@github_data)
    end

    it 'calls organize_commit_dates' do
      expect(controller).to receive(:sort_commit_dates)
      controller.parse_pull_request_data(@github_data)
    end
  end

  describe '#parse_github_repository_data' do
    before(:each) do
      allow(controller).to receive(:count_github_authors_and_dates)
      allow(controller).to receive(:sort_commit_dates)
      controller.instance_variable_set(:@merge_status, {})
      @github_data = {
        "data" => {
          "repository" => {
            "ref" => {
              "target" => {
                "history" => {
                  "edges" => [
                    {
                      "node" => {
                        "author" => {
                          "name" => "Shantanu",
                          "email" => "shantanu@ncsu.edu",
                          "date" => "2018-12-1013:45"
                        }
                      }
                    }
                  ]
                }
              }
            }
          }
        }
      }
    end

    it 'calls process_github_authors_and_dates for each commit object of GitHub data passed in' do
      expect(controller).to receive(:count_github_authors_and_dates).with("Shantanu", "shantanu@ncsu.edu", "2018-12-10")
      controller.parse_repository_data(@github_data)
    end

    it 'calls organize_commit_dates' do
      expect(controller).to receive(:sort_commit_dates)
      controller.parse_repository_data(@github_data)
    end
  end

  describe '#make_github_graphql_request' do
    before(:each) do
      session['github_access_token'] = "qwerty"
    end

    it 'gets data from GitHub api v4(graphql)' do
      response = controller.query_commit_statistics("{\"team\":\"rails\",\"players\":\"36\"}")
      expect(response).to eq("message" => "Bad credentials", "documentation_url" => "https://docs.github.com/graphql")
    end
  end



  describe '#team_statistics' do
    before(:each) do
      controller.instance_variable_set(:@total_additions, 0)
      controller.instance_variable_set(:@total_deletions, 0)
      controller.instance_variable_set(:@total_files_changed, 0)
      controller.instance_variable_set(:@total_commits, 0)
      controller.instance_variable_set(:@head_refs, [])
      controller.instance_variable_set(:@merge_status, [])
    end

    it 'parses team data from github data for merged pull Request' do
      github_data = {
        "data" => {
          "repository" => {
            "pullRequest" => {
              "number" => 8,
              "additions" => 2,
              "deletions" => 1,
              "changedFiles" => 3,
              "mergeable" => "UNKNOWN",
              "merged" => true,
              "headRefOid" => "123abc",
              "commits" => {
                "totalCount" => 16,
                "pageInfo" => {},
                "edges" => []
              }
            }
          }
        }
      }
      controller.team_statistics(github_data, :pull)
      expect(controller.instance_variable_get(:@total_additions)).to eq(2)
      expect(controller.instance_variable_get(:@total_deletions)).to eq(1)
      expect(controller.instance_variable_get(:@total_files_changed)).to eq(3)
      expect(controller.instance_variable_get(:@total_commits)).to eq(16)
      expect(controller.instance_variable_get(:@merge_status)[8]).to eq("MERGED")
    end

    it 'parses team data from github data for non-merged pull Request' do
      github_data = {
        "data" => {
          "repository" => {
            "pullRequest" => {
              "number" => 8,
              "additions" => 2,
              "deletions" => 1,
              "changedFiles" => 3,
              "mergeable" => true,
              "merged" => false,
              "headRefOid" => "123abc",
              "commits" => {
                "totalCount" => 16,
                "pageInfo" => {},
                "edges" => []
              }
            }
          }
        }
      }
      controller.team_statistics(github_data, :pull)
      expect(controller.instance_variable_get(:@total_additions)).to eq(2)
      expect(controller.instance_variable_get(:@total_deletions)).to eq(1)
      expect(controller.instance_variable_get(:@total_files_changed)).to eq(3)
      expect(controller.instance_variable_get(:@total_commits)).to eq(16)
      expect(controller.instance_variable_get(:@merge_status)[8]).to eq(true)
    end
  end

  describe '#organize_commit_dates' do
    before(:each) do
      controller.instance_variable_set(:@dates, "2017-04-05" => 1, "2017-04-13" => 1, "2017-04-14" => 1)
      controller.instance_variable_set(:@parsed_data, "abc" => {"2017-04-14" => 2, "2017-04-13" => 2, "2017-04-05" => 2})
      controller.instance_variable_set(:@total_commits, 0)
    end

    it 'calls organize_commit_dates to sort parsed commits by dates' do
      controller.sort_commit_dates
      expect(controller.instance_variable_get(:@parsed_data)).to eq("abc" => {"2017-04-05" => 2, "2017-04-13" => 2,
                                                                              "2017-04-14" => 2})
    end
  end
end
