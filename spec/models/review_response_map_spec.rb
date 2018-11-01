describe ReviewResponseMap do
  ###
  # Please do not share this file with other teams.
  # Use factories to `build` necessary objects.
  # Please avoid duplicated code as much as you can by moving the code to `before(:each)` block or separated methods.
  # RSpec tutorial video (until 9:32): https://youtu.be/dzkVfaKChSU?t=35s
  # RSpec unit tests examples: https://github.com/expertiza/expertiza/blob/3ce553a2d0258ea05bced910abae5d209a7f55d6/spec/models/response_spec.rb
  ###

  let(:team) { build(:assignment_team) }
  let(:review_response_map) { build(:review_response_map, assignment: assignment, reviewer: participant, reviewee: team) }
  let(:feed_back_response_map) { double('feed_back_response_map', reviewed_object_id: 1) }
  let(:participant) { build(:participant, id: 1, user: build(:student, name: 'no name', fullname: 'no one')) }
  let(:questionnaire) { ReviewQuestionnaire.new(id: 1, questions: [question], max_question_score: 5) }
  let(:assignment) { build(:assignment, id: 1, name: 'Test Assgt') }
  let(:response) { build(:response, id: 1, map_id: 1, response_map: review_response_map, scores: [answer]) }
  let(:answer) { Answer.new(answer: 1, comments: 'Answer text', question_id: 1) }
  let(:question) { Criterion.new(id: 1, weight: 2, break_before: true) }
  let(:feedback) { FeedbackResponseMap.new(id: 1, reviewed_object_id: 1, reviewer_id: 1, reviewee_id: 1) }
  let(:metareview_response_map) {double('metareviewmap') }
  before(:each) do
    allow(response).to receive(:map).and_return(review_response_map)
    allow(review_response_map).to receive(:response).and_return(response)
  end

  it '#questionnaire' do
    allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: 1, used_in_round: 1).and_return([build(:assignment_questionnaire)])
    review_response_map.assignment = assignment
    expect(review_response_map.questionnaire(1)).to eq(questionnaire)
  end

  it '#get_title' do
    expect(review_response_map.get_title).to eq("Review")
  end

  it '#delete' do
    response_map = double("ResponseMap", :reviewed_object_id => 2)
    expect(review_response_map.delete).to equal(review_response_map)
  end

  it '#export_fields' do
    expect(ReviewResponseMap.export_fields('Missing "_options"')).to eq(["contributor", "reviewed by"])
  end

  # it '#export' do
  #   expect(ReviewResponseMap.export('Missing "csv"', 'Missing "parent_id"', 'Missing "_options"')).to eq('Fill this in by hand')
  # end

  # it '#import' do
  #   expect(ReviewResponseMap.import('Missing "row_hash"', 'Missing "_session"', 'Missing "assignment_id"')).to eq('Fill this in by hand')
  # end

  it '#show_feedback' do
    allow(review_response_map).to receive_message_chain(:response, :any?) { true }
    allow(FeedbackResponseMap).to receive(:find_by).and_return(feed_back_response_map)
    allow(feed_back_response_map).to receive_message_chain(:response, :any?) { true }
    allow(feed_back_response_map).to receive_message_chain(:response, :last).and_return(response)
    expect(review_response_map.show_feedback(response)).to eq("<table width=\"100%\"><tr><td align=\"left\" width=\"70%\"><b>Review </b>&nbsp;&nbsp;&nbsp;<a href=\"#\" name= \"review_1Link\" onClick=\"toggleElement('review_1','review');return false;\">show review</a></td><td align=\"left\"><b>Last Reviewed:</b><span>Not available</span></td></tr></table><table id=\"review_1\" style=\"display: none;\" class=\"table table-bordered\"><tr><td><b>Additional Comment: </b></td></tr></table>")
  end

  it '#metareview_response_maps' do
    allow(Response).to receive(:where).and_return([response])
    allow(MetareviewResponseMap).to receive(:where).with(reviewed_object_id: 1).and_return([metareview_response_map])
    expect(review_response_map.metareview_response_maps).to eq([metareview_response_map])
  end

  # it '#get_responses_for_team_round' do
  #   allow(ResponseMap).to receive(:where).with(reviewee_id: 1, type: "ReviewResponseMap").and_return([feed_back_response_map])
  #   allow(review_response_map).to receive_message_chain(:response, :any?) { true }
  #   allow(response).to receive(:round).and_return(1)
  #   allow(response).to receive(:is_submitted).and_return(true)
  #   expect(ReviewResponseMap.get_responses_for_team_round(team, 1)).to eq('Fill this in by hand')
  # end

  # it '#final_versions_from_reviewer' do
  #   expect(ReviewResponseMap.final_versions_from_reviewer('Missing "reviewer_id"')).to eq('Fill this in by hand')
  # end
  #
  # it '#review_response_report' do
  #   expect(ReviewResponseMap.review_response_report('Missing "id"', Assignment.find('Missing "Participant.find(reviewer_id).parent_id"'), 'Missing "type"', 'Missing "review_user"')).to eq('Fill this in by hand')
  # end
  #
  # it '#email' do
  #   expect(review_response_map.email('Missing "defn"', 'Missing "_participant"', Assignment.find('Missing "Participant.find(reviewer_id).parent_id"'))).to eq('Fill this in by hand')
  # end
  #
  # it '#prepare_final_review_versions' do
  #   expect(review_response_map.prepare_final_review_versions(Assignment.find('Missing "Participant.find(reviewer_id).parent_id"'), MetareviewResponseMap.where(reviewed_object_id: 'Missing "self.id"'))).to eq('Fill this in by hand')
  # end
  #
  # it '#prepare_review_response' do
  #   expect(review_response_map.prepare_review_response(Assignment.find('Missing "Participant.find(reviewer_id).parent_id"'), MetareviewResponseMap.where(reviewed_object_id: 'Missing "self.id"'), {  }, nil)).to eq('Fill this in by hand')
  # end
end
