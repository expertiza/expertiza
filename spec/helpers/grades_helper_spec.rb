require 'rails_helper'

describe GradesHelper, :type => :helper do
  before(:each) do
    @assignment = create(:assignment, max_team_size: 1)
    @deadline_type = create(:deadline_type, id: 5, name: 'metareview')
    @deadline_right = create(:deadline_right)
  end

  describe 'get_accordion_title' do
    it 'should render is_first:true if last_topic is nil' do
      get_accordion_title(nil, 'last question')
      expect(response).to render_template(partial: 'response/_accordion', locals: {title: 'last question', is_first: true})
    end
    it 'should render is_first:false if last_topic is not equal to next_topic' do
      get_accordion_title('last question', 'next question')
      expect(response).to render_template(partial: 'response/_accordion', locals: {title: 'next question', is_first: false})
    end
    it 'should render nothing if last_topic is equal to next_topic' do
      get_accordion_title('question', 'question')
      expect(response).to render_template(nil)
    end
  end

  describe 'has_team_and_metareview?' do
    it 'should correctly identify the assignment from an assignment id' do
      params[:id] = @assignment.id
      result = Assignment.find(params[:id])
      expect(result).to eq(@assignment)
    end
    it 'should correctly identify the assignment from a participant id' do
      participant = create(:participant, assignment: @assignment)
      params[:id] = participant.id
      result = Participant.find(params[:id]).parent_id
      expect(result).to eq(@assignment.id)
    end
    it 'should return 0 for an assignment without a team or a metareview deadline after a view action' do
      params[:action] = 'view'
      params[:id] = @assignment.id
      result = has_team_and_metareview?
      expect(result).to be == {has_team: false, has_metareview: false, true_num: 0}
    end
    it 'should return 1 for an assignment with a team but no metareview deadline after a view action' do
      @assignment.max_team_size = 2
      @assignment.save
      params[:action] = 'view'
      params[:id] = @assignment.id
      result = has_team_and_metareview?
      expect(result).to be == {has_team: true, has_metareview: false, true_num: 1}
    end
    it 'should return 1 for an assignment without a team but with a metareview deadline after a view action' do
      @assignment.max_team_size = 1
      @assignment.save
      @assignment_due_date = create(:assignment_due_date, assignment: @assignment, deadline_type: @deadline_type,
        submission_allowed_id: @deadline_right.id, review_allowed_id: @deadline_right.id,
        review_of_review_allowed_id: @deadline_right.id, due_at: '2015-12-30 23:30:12')

      params[:action] = 'view'
      params[:id] = @assignment.id
      result = has_team_and_metareview?
      expect(result).to be == {has_team: false, has_metareview: true, true_num: 1}
    end
    it 'should return 2 for an assignment without a team but with a metareview after a view action' do
      @assignment.max_team_size = 3
      @assignment.save
      @assignment_due_date = create(:assignment_due_date, assignment: @assignment, deadline_type: @deadline_type,
        submission_allowed_id: @deadline_right.id, review_allowed_id: @deadline_right.id,
        review_of_review_allowed_id: @deadline_right.id, due_at: '2015-12-30 23:30:12')

      params[:action] = 'view'
      params[:id] = @assignment.id
      result = has_team_and_metareview?
      expect(result).to be == {has_team: true, has_metareview: true, true_num: 2}
    end
  end

  describe 'participant' do
    it 'should return the correct particpant' do
      new_participant = create(:participant)
      params[:id] = new_participant.id
      result = participant()
      expect(result).to eq(new_participant)
    end
  end

  describe 'rscore_review' do
    it 'should return a record of type :review if available' do
      new_participant = create(:participant)
      questionnaire = create(:questionnaire)
      assignment_questionnaire = create(:assignment_questionnaire, user_id: new_participant.id, questionnaire: questionnaire)
      @questions = {}
      @questions[questionnaire.symbol] = questionnaire.questions
      params[:id] = new_participant.id
      result = rscore_review()
      expect(result).to_not be_nil
    end
    it 'should return nil if no record of type :review is available' do
      new_participant = create(:participant)
      questionnaire = create(:metareview_questionnaire)
      assignment_questionnaire = create(:assignment_questionnaire, user_id: new_participant.id, questionnaire: questionnaire)
      @questions = {}
      @questions[questionnaire.symbol] = questionnaire.questions
      params[:id] = new_participant.id
      result = rscore_review()
      expect(result).to be_nil
    end
  end

  describe 'rscore_metareview' do
    it 'should return a record of type :metareview if available' do
      new_participant = create(:participant)
      questionnaire = create(:metareview_questionnaire)
      assignment_questionnaire = create(:assignment_questionnaire, user_id: new_participant.id, questionnaire: questionnaire)
      @questions = {}
      @questions[questionnaire.symbol] = questionnaire.questions
      params[:id] = new_participant.id
      result = rscore_metareview()
      expect(result).to_not be_nil
    end
    it 'should return nil if no record of type :metareview is available' do
      new_participant = create(:participant)
      questionnaire = create(:questionnaire)
      assignment_questionnaire = create(:assignment_questionnaire, user_id: new_participant.id, questionnaire: questionnaire)
      @questions = {}
      @questions[questionnaire.symbol] = questionnaire.questions
      params[:id] = new_participant.id
      result = rscore_metareview()
      expect(result).to be_nil
    end
  end

  describe 'rscore_feedback' do
    it 'should return a record of type :feedback if available' do
      new_participant = create(:participant)
      questionnaire = create(:author_feedback_questionnaire)
      assignment_questionnaire = create(:assignment_questionnaire, user_id: new_participant.id, questionnaire: questionnaire)
      @questions = {}
      @questions[questionnaire.symbol] = questionnaire.questions
      params[:id] = new_participant.id
      result = rscore_feedback()
      expect(result).to_not be_nil
    end
    it 'should return nil if no record of type :feedback is available' do
      new_participant = create(:participant)
      questionnaire = create(:questionnaire)
      assignment_questionnaire = create(:assignment_questionnaire, user_id: new_participant.id, questionnaire: questionnaire)
      @questions = {}
      @questions[questionnaire.symbol] = questionnaire.questions
      params[:id] = new_participant.id
      result = rscore_feedback()
      expect(result).to be_nil
    end
  end

  describe 'rscore_teammate' do
    it 'should return a record of type :teammate if available' do
      new_participant = create(:participant)
      questionnaire = create(:teammate_review_questionnaire)
      assignment_questionnaire = create(:assignment_questionnaire, user_id: new_participant.id, questionnaire: questionnaire)
      @questions = {}
      @questions[questionnaire.symbol] = questionnaire.questions
      params[:id] = new_participant.id
      result = rscore_teammate()
      expect(result).to_not be_nil
    end
    it 'should return nil if no record of type :teammate is available' do
      new_participant = create(:participant)
      questionnaire = create(:questionnaire)
      assignment_questionnaire = create(:assignment_questionnaire, user_id: new_participant.id, questionnaire: questionnaire)
      @questions = {}
      @questions[questionnaire.symbol] = questionnaire.questions
      params[:id] = new_participant.id
      result = rscore_teammate()
      expect(result).to be_nil
    end
  end

  describe 'p_total_score' do
    it 'should return the grade if available' do
      new_participant = create(:participant, grade: 90)
      questionnaire = create(:questionnaire)
      assignment_questionnaire = create(:assignment_questionnaire, user_id: new_participant.id, questionnaire: questionnaire)
      @questions = {}
      @questions[questionnaire.symbol] = questionnaire.questions
      params[:id] = new_participant.id
      result = p_total_score()
      expect(result).to eq(90)
    end
    it 'should return :total_score if no grade is available' do
      new_participant = create(:participant)
      questionnaire = create(:questionnaire)
      assignment_questionnaire = create(:assignment_questionnaire, user_id: new_participant.id, questionnaire: questionnaire)
      @questions = {}
      @questions[questionnaire.symbol] = questionnaire.questions
      params[:id] = new_participant.id
      result = p_total_score()
      expect(result).to eq(0)
    end
  end


  describe 'p_title' do
    it 'should return a title when the participant has a grade' do
      new_participant = create(:participant)
      params[:id] = new_participant.id
      new_participant.grade = 90
      new_participant.save
      result = p_title()
      expect(result).to eq('A score in blue indicates that the value was overwritten by the instructor or teaching assistant.')
    end
    it 'should return nil when the participant has no grade' do
      new_participant = create(:participant)
      params[:id] = new_participant.id
      result = p_title()
      expect(result).to eq(nil)
    end
  end

  describe 'get_css_style_for_hamer_reputation' do
    it 'should return correct css for a reputation of -0.1' do
      result = get_css_style_for_hamer_reputation(-0.1)
      expect(result).to be == 'c1'
    end
    it 'should return correct css for a reputation of 0' do
      result = get_css_style_for_hamer_reputation(0)
      expect(result).to be == 'c1'
    end
    it 'should return correct css for a reputation of 0.5' do
      result = get_css_style_for_hamer_reputation(0.5)
      expect(result).to be == 'c2'
    end
    it 'should return correct css for a reputation of 1' do
      result = get_css_style_for_hamer_reputation(1)
      expect(result).to be == 'c2'
    end
    it 'should return correct css for a reputation of 1.5' do
      result = get_css_style_for_hamer_reputation(1.5)
      expect(result).to be == 'c3'
    end
    it 'should return correct css for a reputation of 2' do
      result = get_css_style_for_hamer_reputation(2)
      expect(result).to be == 'c4'
    end
    it 'should return correct css for a reputation of 2.1' do
      result = get_css_style_for_hamer_reputation(2.1)
      expect(result).to be == 'c5'
    end
  end

  describe 'get_css_style_for_lauw_reputation' do
    it 'should return correct css for a reputation of -0.1' do
      result = get_css_style_for_lauw_reputation(-0.1)
      expect(result).to be == 'c1'
    end
    it 'should return correct css for a reputation of 0' do
      result = get_css_style_for_lauw_reputation(0)
      expect(result).to be == 'c1'
    end
    it 'should return correct css for a reputation of 0.2' do
      result = get_css_style_for_lauw_reputation(0.2)
      expect(result).to be == 'c2'
    end
    it 'should return correct css for a reputation of 0.4' do
      result = get_css_style_for_lauw_reputation(0.4)
      expect(result).to be == 'c2'
    end
    it 'should return correct css for a reputation of 0.6' do
      result = get_css_style_for_lauw_reputation(0.6)
      expect(result).to be == 'c3'
    end
    it 'should return correct css for a reputation of 0.8' do
      result = get_css_style_for_lauw_reputation(0.8)
      expect(result).to be == 'c4'
    end
    it 'should return correct css for a reputation of 0.9' do
      result = get_css_style_for_lauw_reputation(0.9)
      expect(result).to be == 'c5'
    end
  end
end


