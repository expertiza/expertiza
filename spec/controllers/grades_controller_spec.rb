describe GradesController do
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

  before(:each) do
    allow(AssignmentParticipant).to receive(:find).with('1').and_return(participant)
    allow(participant).to receive(:team).and_return(team)
    stub_current_user(instructor, instructor.role.name, instructor.role)
    allow(Assignment).to receive(:find).with('1').and_return(assignment)
    allow(Assignment).to receive(:find).with(1).and_return(assignment)
  end

  describe '#view' do
    before(:each) do
      allow(Answer).to receive(:compute_scores).with([review_response], [question]).and_return(max: 95, min: 88, avg: 90)
      allow(Participant).to receive(:where).with(parent_id: 1).and_return([participant])
      allow(AssignmentParticipant).to receive(:find).with(1).and_return(participant)
      allow(assignment).to receive(:late_policy_id).and_return(false)
      allow(assignment).to receive(:calculate_penalty).and_return(false)
      session["github_access_token"] = "QWERTY"
    end

    context 'when current assignment varies rubrics by round' do
      it 'retrieves questions, calculates scores and renders grades#view page' do
        allow(assignment).to receive(:vary_by_round).and_return(true)
        allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: 1, used_in_round: 2).and_return([assignment_questionnaire])
        allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: 1, questionnaire_id: 1).and_return([assignment_questionnaire])
        params = {id: 1}
        get :view, params
        expect(controller.instance_variable_get(:@questions)[:review1].size).to eq(1)
        expect(response).to render_template(:view)
      end
      end

    # This test is expected to fail due to the commented code on lines 38-42 in grades_controller. One of the aims of
    # E2111
    # is to decouple this code from the grades controller, where both the code itself and the testing are
    # significantly coupled into the grades controller.
    context 'when user hasn\'t logged in to GitHub' do
      before(:each) do
        @params = {id: 900}
        session["github_access_token"] = nil
      end

      it 'stores the current assignment id and the view action' do
        get :view, @params
        expect(session["assignment_id"]).to eq("900")
        expect(session["github_view_type"]).to eq("view_scores")
      end

      it 'redirects user to GitHub authorization page' do
        get :view, @params
        expect(response).to redirect_to(authorize_github_grades_path)
      end
    end
  
    context 'when current assignment does not vary rubric by round' do
        it 'calculates scores and renders grades#view page' do
          allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: 1, used_in_round: 2).and_return([])
          allow(ReviewResponseMap).to receive(:get_assessments_for).with(team).and_return([review_response])
          params = {id: 1}
          get :view, params
          expect(controller.instance_variable_get(:@questions)[:review].size).to eq(1)
          expect(response).to render_template(:view)
        end
      end
  end
  
  describe '#view_my_scores' do
    before(:each) do
      allow(Participant).to receive(:find_by).with(id: '1').and_return(participant)
      allow(Participant).to receive(:find).with('1').and_return(participant)
    end

    context 'when view_my_scores page is not allowed to access' do
      it 'shows a flash error message and redirects to root path (/)' do
        session[:user] = nil
        params = {id: 1}
        get :view_my_scores, params
        expect(response).to redirect_to('/')
      end
    end

    context 'when view_my_scores page is allow to access' do
      it 'renders grades#view_my_scores page' do
        allow(TeamsUser).to receive(:where).with(any_args).and_return([double('TeamsUser', team_id: 1)])
        allow(Team).to receive(:find).with(1).and_return(team)
        allow(AssignmentQuestionnaire).to receive(:find_by).with(assignment_id: 1, questionnaire_id: 1).and_return(assignment_questionnaire)
        allow(AssignmentQuestionnaire).to receive(:where).with(any_args).and_return([assignment_questionnaire])
        allow(review_questionnaire).to receive(:get_assessments_round_for).with(participant, 1).and_return([review_response])
        allow(Answer).to receive(:compute_scores).with([review_response], [question]).and_return(max: 95, min: 88, avg: 90)
        allow(Participant).to receive(:where).with(parent_id: 1).and_return([participant])
        allow(AssignmentParticipant).to receive(:find).with(1).and_return(participant)
        allow(assignment).to receive(:late_policy_id).and_return(false)
        allow(assignment).to receive(:calculate_penalty).and_return(false)
        allow(assignment).to receive(:compute_total_score).with(any_args).and_return(100)
        params = {id: 1}
        session = {user: instructor}
        get :view_my_scores, params, session
        expect(response).to render_template(:view_my_scores)
      end
    end
  end

  xdescribe '#view_team' do
    it 'renders grades#view_team page' do
      allow(participant).to receive(:team).and_return(team)
      params = {id: 1}
      get :view_team, params
      expect(response).to render_template(:view_team)
    end
  end

  describe '#view_team' do
    render_views
    context 'when view_team page is viewed by a student who is also a TA for another course' do
      it 'renders grades#view_team page' do
        allow(participant).to receive(:team).and_return(team)
        allow(AssignmentQuestionnaire).to receive(:find_by).with(assignment_id: 1, questionnaire_id: 1).and_return(assignment_questionnaire)
        allow(AssignmentQuestionnaire).to receive(:where).with(any_args).and_return([assignment_questionnaire])
        allow(assignment).to receive(:late_policy_id).and_return(false)
        allow(assignment).to receive(:calculate_penalty).and_return(false)
        allow(assignment).to receive(:compute_total_score).with(any_args).and_return(100)
        allow(review_questionnaire).to receive(:get_assessments_round_for).with(participant, 1).and_return([review_response])
        allow(Answer).to receive(:compute_scores).with([review_response], [question]).and_return(max: 95, min: 88, avg: 90)
        params = {id: 1}
        allow(TaMapping).to receive(:exists?).with(ta_id: 1, course_id: 1).and_return(true)
        stub_current_user(ta, ta.role.name, ta.role)
        get :view_team, params
        expect(response.body).not_to have_content "TA"
      end
    end
  end

  describe '#edit' do
    it 'renders grades#edit page' do
      allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: 1, used_in_round: 2).and_return([])
      assignment_questionnaire.used_in_round = nil
      allow(AssignmentQuestionnaire).to receive(:find_by).with(assignment_id: 1, questionnaire_id: 1).and_return(assignment_questionnaire)
      allow(review_questionnaire).to receive(:get_assessments_for).with(participant).and_return([review_response])
      allow(Answer).to receive(:compute_scores).with([review_response], [question]).and_return(max: 95, min: 88, avg: 90)
      allow(assignment).to receive(:compute_total_score).with(any_args).and_return(100)
      params = {id: 1}
      get :edit, params
      expect(response).to render_template(:edit)
    end
  end

  describe '#instructor_review' do
    context 'when review exists' do
      it 'redirects to response#edit page' do
        allow(AssignmentParticipant).to receive(:find_or_create_by).with(user_id: 6, parent_id: 1).and_return(participant)
        allow(participant).to receive(:new_record?).and_return(false)
        allow(ReviewResponseMap).to receive(:find_or_create_by).with(reviewee_id: 1, reviewer_id: 1, reviewed_object_id: 1).and_return(review_response_map)
        allow(review_response_map).to receive(:new_record?).and_return(false)
        allow(Response).to receive(:find_by).with(map_id: 1).and_return(review_response)
        params = {id: 1}
        session = {user: instructor}
        get :instructor_review, params, session
        expect(response).to redirect_to('/response/edit?return=instructor')
      end
    end

    context 'when review does not exist' do
      it 'redirects to response#new page' do
        allow(AssignmentParticipant).to receive(:find_or_create_by).with(user_id: 6, parent_id: 1).and_return(participant2)
        allow(participant2).to receive(:new_record?).and_return(false)
        allow(ReviewResponseMap).to receive(:find_or_create_by).with(reviewee_id: 1, reviewer_id: 2, reviewed_object_id: 1).and_return(review_response_map)
        allow(review_response_map).to receive(:new_record?).and_return(true)
        allow(Response).to receive(:find_by).with(map_id: 1).and_return(review_response)
        params = {id: 1}
        session = {user: instructor}
        get :instructor_review, params, session
        expect(response).to redirect_to('/response/new?id=1&return=instructor')
      end
    end
  end

  describe '#update' do
    before(:each) do
      allow(participant).to receive(:update_attribute).with(any_args).and_return(participant)
    end
    context 'when total is not equal to participant\'s grade' do
      it 'updates grades and redirects to grades#edit page' do
        params = {
          id: 1,
          total_score: 98,
          participant: {
            grade: 96
          }
        }
        post :update, params
        expect(flash[:note]).to eq("The computed score will be used for #{participant.user.name}.")
        expect(response).to redirect_to('/grades/1/edit')
      end
    end

    context 'when total is equal to participant\'s grade' do
      it 'redirects to grades#edit page' do
        params = {
          id: 1,
          total_score: 98,
          participant: {
            grade: 98
          }
        }
        post :update, params
        expect(flash[:note]).to eq("The computed score will be used for #{participant.user.name}.")
        expect(response).to redirect_to('/grades/1/edit')
      end
    end
  end

  describe '#save_grade_and_comment_for_submission' do
    it 'saves grade and comment for submission and refreshes the grades#view_team page' do
      allow(AssignmentParticipant).to receive(:find_by).with(id: '1').and_return(participant)
      allow(participant).to receive(:team).and_return(build(:assignment_team, id: 2, parent_id: 8))
      params = {
        participant_id: 1,
        grade_for_submission: 100,
        comment_for_submission: 'comment'
      }
      post :save_grade_and_comment_for_submission, params
      expect(flash[:error]).to be nil
      expect(response).to redirect_to('/grades/view_team?id=1')
    end
  end


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

  describe '#retrieve_repository_data' do
    before(:each) do
      allow(controller).to receive(:get_github_repository_details).and_return("pr" => "details")
      allow(controller).to receive(:parse_repository_data)
    end

    it 'gets details for each repo link submitted, excluding those for expertiza and servo' do
      expect(controller).to receive(:get_github_repository_details).with("repository_name" => "website",
                                                                         "owner_name" => "Shantanu")
      expect(controller).to receive(:get_github_repository_details).with("repository_name" => "OODD",
                                                                         "owner_name" => "Edward")
      controller.retrieve_repository_data(["https://github.com/Shantanu/website", "https://github.com/Edward/OODD",
                                           "https://github.com/expertiza/expertiza",
                                           "https://github.com/Shantanu/expertiza]"])
    end

    it 'calls parse_github_data_repo on each of the PR details' do
      expect(controller).to receive(:parse_repository_data).with("pr" => "details").twice
      controller.retrieve_repository_data(["https://github.com/Shantanu/website", "https://github.com/Edward/OODD"])
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
  describe '#action_allowed' do
    context 'when the student does not belong to a team' do
      it 'returns false' do 
        params = {action: 'view_team'}
        session[:user].role.name = 'Student'
        expect(controller.action_allowed?).to eq(false)
      end
    end
    context 'when the user is an instructor' do
      it 'returns true' do 
        params = {action: 'view_team'} 
        session[:user].role.name = 'Instructor'
        expect(controller.action_allowed?).to eq(true)

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

  describe '#view_github_metrics' do
    context 'when user hasn\'t logged in to GitHub' do
      before(:each) do
        @params = {id: 900}
        session["github_access_token"] = nil
      end

      it 'stores the current participant id and the view action' do
        get :view_github_metrics, @params
        expect(session["participant_id"]).to eq("900")
        expect(session["github_view_type"]).to eq("view_submissions")
      end

      it 'redirects user to GitHub authorization page' do
        get :view_github_metrics, @params
        expect(response).to redirect_to(authorize_github_grades_path)
      end
    end

    context 'when user has logged in to GitHub' do
      before(:each) do
        session["github_access_token"] = "qwerty"
        allow(controller).to receive(:query_pull_request_status).and_return("status")
        allow(controller).to receive(:retrieve_github_data).and_return("data")
        allow(controller).to receive(:query_all_merge_statuses).and_return("status")
      end

      it 'stores the GitHub access token for later use' do
        get :view_github_metrics, id: '1'
        expect(controller.instance_variable_get(:@token)).to eq("qwerty")
      end

      it 'calls retrieve_github_data to retrieve data from GitHub' do
        expect(controller).to receive(:retrieve_github_data)
        get :view_github_metrics, id: '1'
      end

      it 'calls retrieve_check_run_statuses to retrieve check runs data' do
        expect(controller).to receive(:query_all_merge_statuses)
        get :view_github_metrics, id: '1'
      end
    end
  end

  describe '#authorize_github' do
    it 'redirects the user to GitHub authorization page' do
      get :authorize_github
      expect(response).to redirect_to("https://github.com/login/oauth/authorize?client_id=qwerty12345")
    end
  end

  describe '#get_github_repository_details' do
    before(:each) do
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
                  history(first: 100) {
                    edges {
                      node {
                        id author {
                          name email date
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }"
      )
      details = controller.get_github_repository_details(hyperlink_data)
      expect(details).to eq("github": "github")
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
      data = controller.pull_request_data("https://github.com/expertiza/expertiza")
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
      controller.count_github_authors_and_dates("author", "date")
      expect(controller.instance_variable_get(:@authors)).to eq("author" => 1)
      expect(controller.instance_variable_get(:@dates)).to eq("date" => 1)
      expect(controller.instance_variable_get(:@parsed_data)).to eq("author" => {"date" => 1})

      controller.count_github_authors_and_dates("author", "date")
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
                          "name" => "Shantanu"
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
      expect(controller).to receive(:team_statistics).with(@github_data)
      controller.parse_pull_request_data(@github_data)
    end

    it 'calls process_github_authors_and_dates for each commit object of GitHub data passed in' do
      expect(controller).to receive(:count_github_authors_and_dates).with("Shantanu", "2018-12-10")
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
      expect(controller).to receive(:count_github_authors_and_dates).with("Shantanu", "2018-12-10")
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

  describe 'get_query' do
    before(:each) do
      controller.instance_variable_set(:@end_cursor, "")
    end
    it 'constructs the graphql query' do
      query = {
        query:   "query {
        repository(owner: \"expertiza\", name:\"expertiza\") {
          pullRequest(number: 1228) {
            number additions deletions changedFiles mergeable merged headRefOid
              commits(first:100 ){
                totalCount
                  pageInfo{
                    hasNextPage startCursor endCursor
                    }
                      edges{
                        node{
                          id  commit{
                                author{
                                  name
                                }
                               additions deletions changedFiles committedDate
                        }}}}}}}"
      }
      hyperlink_data = {}
      hyperlink_data["owner_name"] = "expertiza"
      hyperlink_data["repository_name"] = "expertiza"
      hyperlink_data["pull_request_number"] = "1228"
      response = controller.get_query(hyperlink_data)
      expect(response).to eq(query)
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
      controller.team_statistics(
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
      )
      expect(controller.instance_variable_get(:@total_additions)).to eq(2)
      expect(controller.instance_variable_get(:@total_deletions)).to eq(1)
      expect(controller.instance_variable_get(:@total_files_changed)).to eq(3)
      expect(controller.instance_variable_get(:@total_commits)).to eq(16)
      expect(controller.instance_variable_get(:@merge_status)[8]).to eq("MERGED")
    end

    it 'parses team data from github data for non-merged pull Request' do
      controller.team_statistics(
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
      )
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
    end

    it 'calls organize_commit_dates to sort parsed commits by dates' do
      controller.sort_commit_dates
      expect(controller.instance_variable_get(:@parsed_data)).to eq("abc" => {"2017-04-05" => 2, "2017-04-13" => 2,
                                                                              "2017-04-14" => 2})
    end
  end
  describe '#redirect_when_disallowed' do
    context 'when a participant without a team exists' do
      it 'redirects to /' do
        params = {id: 1}
        session
        allow(participant).to receive(:team).and_return(nil)
        allow(AssignmentParticipant).to receive(:find).with(1).and_return(participant)
        allow(TeamsUser).to receive(:team_id).and_return(1)
        get :view_my_scores, params
        expect(response).to redirect_to('/')
      end
    end 
  end
end
