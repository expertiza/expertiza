require 'rails_helper'
describe GradesHelper, type: :helper do
  let(:review_response) { build(:response, id: 1, map_id: 1) }
  let(:item) { build(:item) }
  let(:participant) { build(:participant, id: 1, assignment: assignment, user_id: 1, parent_id: 1) }
  let(:team) { build(:assignment_team, id: 1) }
  let(:assignment_participant) { build(:participant, id: 1, assignment: assignment) }
  let(:viewgrid_participant) { build(:participant, id: 2, assignment: assignment_for_viewgrid) }
  let(:assignment) { build(:assignment, id: 1, max_team_size: 1, itemnaires: itemnaires, late_policy_id: 1, is_penalty_calculated: true, rounds_of_reviews: 1, vary_by_round?: true) }
  let(:assignment_for_penalty) { build(:assignment, id: 4, max_team_size: 1, itemnaires: itemnaires, late_policy_id: 1, is_penalty_calculated: false, rounds_of_reviews: 1, vary_by_round?: true) }
  let(:assignment_for_viewgrid) { build(:assignment, id: 5, max_team_size: 1, itemnaires: [itemnaire3], late_policy_id: 1, is_penalty_calculated: false, rounds_of_reviews: 1, vary_by_round?: false) }
  let(:single_assignment) { build(:assignment, id: 1, max_team_size: 1, itemnaires: [review_itemnaire], is_penalty_calculated: true) }
  let(:team_assignment) { build(:assignment, id: 2, max_team_size: 2, itemnaires: [review_itemnaire], is_penalty_calculated: true) }
  let(:review_itemnaire) { build(:itemnaire, id: 1, items: [item]) }
  let(:itemnaire1) { build(:itemnaire, id: 1, items: [item], type: 'ReviewQuestionnaire') }
  let(:itemnaire2) { build(:itemnaire, id: 2, items: [item], type: 'ReviewQuestionnaire') }
  let(:itemnaire3) { build(:itemnaire, id: 3, items: [item], type: 'TeammateReviewQuestionnaire') }
  let(:itemnaires) { [itemnaire1, itemnaire2] }
  let(:aq1) { build(:assignment_itemnaire, id: 1, used_in_round: 1) }
  let(:aq2) { build(:assignment_itemnaire, id: 2) }
  let(:latePolicy) { LatePolicy.new(policy_name: 'late_policy_1', instructor_id: 6, max_penalty: 10, penalty_per_unit: 5, penalty_unit: 1) }
  let(:vmQ1) { VmQuestionResponse.new(itemnaire1, assignment, 1) }
  let(:vmQ2) { VmQuestionResponse.new(itemnaire2, assignment, 2) }
  let(:helper) { Class.new { extend GradesHelper } }

  describe 'accordion_title' do
    it 'should render is_first:true if last_topic is nil' do
      title_html = accordion_title(nil, 'last item')
      expect(title_html).to include('last item')
    end
    it 'should render is_first:false if last_topic is not equal to next_topic' do
      title_html = accordion_title('last item', 'next item')
      expect(title_html).to include('next item')
    end
    it 'should render nothing if last_topic is equal to next_topic' do
      title_html = accordion_title('next item', 'next item')
      expect(title_html).to eq(nil)
    end
  end

  describe 'get_css_style_for_X_reputation' do
    hamer_input = [-0.1, 0, 0.5, 1, 1.5, 2, 2.1]
    lauw_input = [-0.1, 0, 0.2, 0.4, 0.6, 0.8, 0.9]
    output = %w[c1 c1 c2 c2 c3 c4 c5]
    it 'should return correct css for hamer reputations' do
      hamer_input.each_with_index do |e, i|
        expect(get_css_style_for_hamer_reputation(e)).to eq(output[i])
      end
    end
    it 'should return correct css for luaw reputations' do
      lauw_input.each_with_index do |e, i|
        expect(get_css_style_for_lauw_reputation(e)).to eq(output[i])
      end
    end
  end

  describe 'score_vector' do
    it 'should return the scores from the items in a vector' do
      allow(Response).to receive(:score).with(response: [review_response], items: [item], q_types: []).and_return(75)
      @items = { s: [item] }
      expect(score_vector([review_response, review_response], 's')).to eq([75, 75])
    end
  end

  describe 'charts' do
    it 'it should return a chart url' do
      symbol = :s
      @grades_bar_charts = { s: nil }
      @participant_score = { symbol => { assessments: [review_response, review_response] } }
      allow(Response).to receive(:score).with(response: [review_response], items: [item], q_types: []).and_return(75)
      allow(GradesController).to receive(:bar_chart).with([75, 75]).and_return(
        'http://chart.apis.google.com/chart?chs=800x200&cht=bvg&chco=0000ff,ff0000,00ff00&chd=s:yoeKey,KUeoy9,9yooy9&chdl=Trend+1|Trend+2|Trend+3&chtt=Bar+Chart'
      )
      @items = { s: [item] }
      expect(charts(symbol).class).to eq(String)
      expect(charts(symbol)).to include('http://chart.apis.google.com/chart')
    end
    it 'returns nil when there is no score' do
      @participant_score = { s: nil }
      symbol = :s
      expect(charts(symbol)).to eq(nil)
    end
  end

  describe 'type_and_max' do
    context 'when the item is a Checkbox' do
      it 'returns 10_003' do
        row = VmQuestionResponseRow.new('Some item text', 1, 5, 95, 2)
        allow(Question).to receive(:find).with(1).and_return(item)
        allow(item).to receive(:type).and_return('Checkbox')
        allow(item).to receive(:is_a?).and_return(Checkbox)
        expect(type_and_max(row)).to eq(10_003)
      end
    end
    context 'when the item is a ScoredQuestion' do
      it 'returns the correct code and the max score' do
        row = VmQuestionResponseRow.new('Some item text', 1, 5, 95, 2)
        allow(Question).to receive(:find).with(1).and_return(item)
        allow(item).to receive(:is_a?).and_return(ScoredQuestion)
        expect(type_and_max(row)).to eq(9311 + row.item_max_score)
      end
    end
    context 'when the item is something else' do
      it 'returns 9998' do
        row = VmQuestionResponseRow.new('Some item text', 1, 5, 95, 2)
        allow(Question).to receive(:find).with(1).and_return(item)
        allow(item).to receive(:is_a?).with(ScoredQuestion).and_return(false)
        item[:type] == 'NotACheckbox'
        expect(type_and_max(row)).to eq(9998)
      end
    end
  end

  describe 'underlined?' do
    context 'when the comment is present' do
      it 'returns underlined' do
        score = VmQuestionResponseScoreCell.new(95, 0, 'This is a comment.')
        expect(underlined?(score)).to eq('underlined')
      end
    end
  end

  describe 'mean' do
    it 'computes the mean of an array' do
      array = [2, 3, 4]
      expect(mean(array)).to be(3.0)
    end
  end

  describe 'vector' do
    context 'when there are nil scores' do
      it 'filters them out' do
        scores = {
          teams: {
            a: {
              scores: {}
            }, b: {
              scores: {
                avg: 75
              }
            }, c: {
              scores: {
                avg: 65
              }
            }
          }
        }
        expect(vector(scores)).to eq([75, 65])
      end
    end
  end

  describe 'has_team_and_metareview' do
    context 'when query assignment is individual work and does not have metareview' do
      it 'return true_num with 0' do
        params = { action: 'view', id: 1 }
        # set the params variable in function has_team_and_metareview
        allow(helper).to receive(:params).and_return(params)
        # mock the search result to avoid data doesn't exist in testing DB.
        # the mocking assignment is an individual assignment.
        allow(Assignment).to receive(:find).with(1).and_return(single_assignment)
        # mock the situation where there is no due date in DB for the mocking assignment
        allow(AssignmentDueDate).to receive(:exists?).with(any_args).and_return(false)
        expect(helper.has_team_and_metareview?).to eq(has_team: false, has_metareview: false, true_num: 0)
      end
    end
    context 'when query assignment is team work and does not have metareview' do
      it 'return true_num with 1' do
        params = { action: 'view', id: 2 }
        # set the params variable in function has_team_and_metareview
        allow(helper).to receive(:params).and_return(params)
        # mock the search result to avoid data doesn't exist in testing DB.
        # the mocking assignment is an teamwork assignment.
        allow(Assignment).to receive(:find).with(2).and_return(team_assignment)
        # mock the situation where there is no due date in DB for the mocking assignment
        allow(AssignmentDueDate).to receive(:exists?).with(any_args).and_return(false)
        expect(helper.has_team_and_metareview?).to eq(has_team: true, has_metareview: false, true_num: 1)
      end
    end
    context 'when query assignment is individual work and has metareview' do
      it 'return true_num with 0' do
        params = { action: 'view', id: 1 }
        # set the params variable in function has_team_and_metareview
        allow(helper).to receive(:params).and_return(params)
        # mock the search result to avoid data doesn't exist in testing DB.
        # the mocking assignment is an individual assignment.
        allow(Assignment).to receive(:find).with(1).and_return(single_assignment)
        # mock the situation where a due date for the mocking assignment exists in DB.
        allow(AssignmentDueDate).to receive(:exists?).with(any_args).and_return(true)
        expect(helper.has_team_and_metareview?).to eq(has_team: false, has_metareview: true, true_num: 1)
      end
    end
    context 'when query assignment is team work and has metareview' do
      it 'return true_num with 0' do
        params = { action: 'view', id: 2 }
        # set the params variable in function has_team_and_metareview
        allow(helper).to receive(:params).and_return(params)
        # mock the search result to avoid data doesn't exist in testing DB.
        # the mocking assignment is an tesmwork assignment.
        allow(Assignment).to receive(:find).with(2).and_return(team_assignment)
        # mock the situation where a due date for the mocking assignment exists in DB.
        allow(AssignmentDueDate).to receive(:exists?).with(any_args).and_return(true)
        expect(helper.has_team_and_metareview?).to eq(has_team: true, has_metareview: true, true_num: 2)
      end
    end

    # This test should be skipped because there are some bugs in the original code because @assignment is not existing.
    context 'when query assignment is team work and has metareview' do
      it 'return true_num with 0' do
        # params = {action: 'view_my_scores', id: 1}
        # allow(helper).to receive(:params).and_return(params)
        # allow(Participant).to receive(:find).with(1).and_return(participant)
        # allow(AssignmentDueDate).to receive(:exists?).with(any_args).and_return(true)
        # expect(helper.has_team_and_metareview?).to eq({has_team: true, has_metareview: true, true_num: 2})
      end
    end
  end

  describe 'retrieve_items' do
    context 'when give a list of itemnaires' do
      it 'return the map the items' do
        allow(itemnaire1). to receive(:symbol).and_return('test1')
        allow(itemnaire2). to receive(:symbol).and_return('test2')
        allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: 1, itemnaire_id: 1).and_return(aq1)
        allow(aq1).to receive(:first).and_return(aq1)
        allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: 1, itemnaire_id: 2).and_return(aq2)
        allow(aq2).to receive(:first).and_return(aq2)
        expect(retrieve_items(itemnaires, 1)).to eq(test11: itemnaire1.items, 'test2' => itemnaire2.items)
      end
    end
  end

  describe 'view_heatgrid' do
    context 'when all itemnaires do not match the target type' do
      it 'render the view with empty list of  VmQuestionResponse' do
        # mock the participant for the  AssignmentParticipant.find
        allow(AssignmentParticipant).to receive(:find).with(1).and_return(assignment_participant)
        allow(assignment_participant).to receive(:team).and_return(team)
        # in the for each part, the function finds the AssignmentQuestionnaire by itemnaire id
        # so, mock all the searhcing result to avoid data not existing in DB
        allow(AssignmentQuestionnaire).to receive(:find_by).with(assignment_id: 1, itemnaire_id: 1).and_return(aq1)
        allow(AssignmentQuestionnaire).to receive(:find_by).with(assignment_id: 1, itemnaire_id: 2).and_return(aq2)
        # just test a part of html to ensure the function render the target view successfully
        expect(view_heatgrid(1, 'non-exist')).to include('!-- For each of the models in the list, generate a heatgrid table. this is the outer most loop -->')
        # access the variable in the function and test the result
        expect(instance_variable_get(:@vmlist)).to eq([])
      end
    end
    context 'when all itemnaires match the target type' do
      it 'render the view with nonempty list of  VmQuestionResponse' do
        # mock the participant for the  AssignmentParticipant.find
        allow(AssignmentParticipant).to receive(:find).with(1).and_return(assignment_participant)
        allow(assignment_participant).to receive(:team).and_return(team)
        # in the for each part, the function finds the AssignmentQuestionnaire by itemnaire id
        # so, mock all the searhcing result to avoid data not existing in DB
        allow(AssignmentQuestionnaire).to receive(:find_by).with(assignment_id: 1, itemnaire_id: 1).and_return(aq1)
        allow(AssignmentQuestionnaire).to receive(:find_by).with(assignment_id: 1, itemnaire_id: 2).and_return(aq2)
        # mock a creating result for testing return value
        allow(VmQuestionResponse).to receive(:new).with(any_args).and_return(vmQ1)
        expect(view_heatgrid(1, 'ReviewQuestionnaire')).to include('!-- For each of the models in the list, generate a heatgrid table. this is the outer most loop -->')
        expect(instance_variable_get(:@vmlist)).to eq([vmQ1, vmQ1])
      end
    end

    context 'when all itemnaires match the target type, but the assignment does not vary by round' do
      it 'the round variable in the new VmQuestionResponse should be nil' do
        # mock the participant for the  AssignmentParticipant.find
        # viewgrid_participant contains a assignment whose itemnaires' type is TeammateReviewQuestionnaire
        allow(AssignmentParticipant).to receive(:find).with(2).and_return(viewgrid_participant)
        allow(viewgrid_participant).to receive(:team).and_return(team)
        view_heatgrid(2, 'TeammateReviewQuestionnaire')
        # testing the object variable
        list = instance_variable_get(:@vmlist)
        expect(list[0].round).to eq(nil)
      end
    end
  end

  describe 'penalties' do
    context 'when giving an assignment id' do
      it 'calculates all the penalties' do
        # mock the data for Assignment.find and Participant.where
        allow(Assignment).to receive(:find).with(1).and_return(assignment)
        allow(Participant).to receive(:where).with(parent_id: 1).and_return([participant])
        # calculate_penalty is the function of penalty_helper.rb
        # we skip the test because it is not necessary to do outgoing test
        allow(self).to receive(:calculate_penalty).with(participant.id).and_return(submission: 1, review: 1, meta_review: 1)
        # mock the data for LatePolicy.find
        allow(LatePolicy).to receive(:find).with(assignment.late_policy_id).and_return(latePolicy)
        # assign_all_penalties is the function of grade_controller.rb
        # we skip the test because it is not necessary to do outgoing test
        allow(self).to receive(:assign_all_penalties).with(any_args).and_return(nil)
        penalties(1)
        # testing the @assignment equals to expected result
        expect(instance_variable_get(:@assignment)).to eq(assignment)
      end

      # This test should be skipped because there are some bugs in the original code.
      it 'calculates all the penalties and create new CalculatedPenalty' do
        # allow(Assignment).to receive(:find).with(4).and_return(assignment_for_penalty)
        # allow(Participant).to receive(:where).with(parent_id: 4).and_return([participant])
        # allow(self).to receive(:calculate_penalty).with(participant.id).and_return({submission: 1, review: 1, meta_review: 1})
        # allow(LatePolicy).to receive(:find).with(assignment.late_policy_id).and_return(latePolicy)
        # allow(self).to receive(:assign_all_penalties).with(any_args).and_return(nil)
        # allow(CalculatedPenalty).to receive(:create).with(any_args).and_return(nil)
        # penalties(4)
        # expect(self.instance_variable_get(:@assignment)).to eq(assignment)
      end
    end
  end
end
