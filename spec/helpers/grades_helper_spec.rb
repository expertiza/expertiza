require 'rails_helper'
require 'selenium-webdriver'

describe GradesHelper, type: :helper do
  before(:each) do
    @assignment = create(:assignment, max_team_size: 1)
    @assignment2 = create(:assignment, name: 'whatever', max_team_size: 3)
    @deadline_type = create(:deadline_type, id: 5, name: 'metareview')
    @deadline_right = create(:deadline_right)
    @new_participant = create(:participant, assignment: @assignment)
    @participant = create(:participant, assignment: @assignment2)
    @assignment_team = create(:assignment_team, assignment: @assignment)
    @questionnaire = create(:questionnaire)
    @metareview_questionnaire = create(:metareview_questionnaire)
    @author_feedback_questionnaire = create(:author_feedback_questionnaire)
    @teammate_review_questionnaire = create(:teammate_review_questionnaire)
    create(:assignment_questionnaire, user_id: @new_participant.id, questionnaire: @questionnaire)
    create(:assignment_questionnaire, user_id: @new_participant.id, questionnaire: @metareview_questionnaire)
    create(:assignment_questionnaire, user_id: @new_participant.id, questionnaire: @author_feedback_questionnaire)
    create(:assignment_questionnaire, user_id: @new_participant.id, questionnaire: @teammate_review_questionnaire)

    @questions = {}
    @questions[@questionnaire.symbol] = @questionnaire.questions
    @questions[@metareview_questionnaire.symbol] = @metareview_questionnaire.questions
    @questions[@author_feedback_questionnaire.symbol] = @author_feedback_questionnaire.questions
    @questions[@teammate_review_questionnaire.symbol] = @teammate_review_questionnaire.questions

    create(
      :assignment_due_date,
      assignment: @assignment2,
      deadline_type: @deadline_type,
      submission_allowed_id: @deadline_right.id,
      review_allowed_id: @deadline_right.id,
      review_of_review_allowed_id: @deadline_right.id,
      due_at: '2015-12-30 23:30:12'
    )
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
      params[:id] = @new_participant.id
      result = Participant.find(params[:id]).parent_id
      expect(result).to eq(@assignment.id)
    end
    it 'should return 0 for an assignment without a team or a metareview after a view action' do
      params[:action] = 'view'
      params[:id] = @assignment.id
      result = has_team_and_metareview?
      expect(result).to be == {has_team: false, has_metareview: false, true_num: 0}
    end
    it 'should return 1 for an assignment with a team but no metareview after a view action' do
      @assignment.max_team_size = 2
      @assignment.save
      params[:action] = 'view'
      params[:id] = @assignment.id
      result = has_team_and_metareview?
      expect(result).to be == {has_team: true, has_metareview: false, true_num: 1}
    end
    it 'should return 1 for an assignment without a team but with a metareview after a view action' do
      @assignment2.max_team_size = 1
      @assignment2.save
      params[:action] = 'view'
      params[:id] = @assignment2.id
      result = has_team_and_metareview?
      expect(result).to be == {has_team: false, has_metareview: true, true_num: 1}
    end
    it 'should return 2 for an assignment with a team and with a metareview after a view action' do
      params[:action] = 'view'
      params[:id] = @assignment2.id
      result = has_team_and_metareview?
      expect(result).to be == {has_team: true, has_metareview: true, true_num: 2}
    end
  end

  describe 'participant' do
    it 'should return the correct particpant' do
      new_participant = create(:participant)
      params[:id] = new_participant.id
      result = participant
      expect(result).to eq(new_participant)
    end
  end

  describe 'rscore_X' do
    it 'should return records of each review type if available' do
      params[:id] = @new_participant.id
      expect(rscore_review).to_not be_nil
      expect(rscore_metareview).to_not be_nil
      expect(rscore_feedback).to_not eq(nil)
      expect(rscore_teammate).to_not eq(nil)
    end
    it 'should return nil if review types are not available' do
      params[:id] = @participant.id
      expect(rscore_review).to be_nil
      expect(rscore_metareview).to be_nil
      expect(rscore_feedback).to be_nil
      expect(rscore_teammate).to be_nil
    end
  end

  describe 'p_total_score' do
    it 'should return the grade if available' do
      graded_participant = create(:participant, grade: 90)
      create(:assignment_questionnaire, user_id: graded_participant.id, questionnaire: @questionnaire)
      @questions[@questionnaire.symbol] = @questionnaire.questions
      params[:id] = graded_participant.id
      expect(p_total_score).to eq(90)
    end
    it 'should return :total_score if no grade is available' do
      create(:assignment_questionnaire, user_id: @new_participant.id, questionnaire: @questionnaire)
      @questions[@questionnaire.symbol] = @questionnaire.questions
      params[:id] = @new_participant.id
      expect(p_total_score).to eq(0)
    end
  end

  describe 'p_title' do
    it 'should return a title when the participant has a grade' do
      params[:id] = @new_participant.id
      @new_participant.grade = 90
      @new_participant.save
      expect(p_title).to eq('A score in blue indicates that the value was overwritten by the instructor or teaching assistant.')
    end
    it 'should return nil when the participant has no grade' do
      params[:id] = @new_participant.id
      expect(p_title).to eq(nil)
    end
  end

  describe 'get_css_style_for_X_reputation' do
    hamer_input = [-0.1, 0, 0.5, 1, 1.5, 2, 2.1]
    lauw_input = [-0.1, 0, 0.2, 0.4, 0.6, 0.8, 0.9]
    output = %w(c1 c1 c2 c2 c3 c4 c5)
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
end

#########################
# Functional Cases
#########################
describe GradesHelper, type: :feature do
  before(:each) do
    @assignment = create(:assignment)
    @assignment_team = create(:assignment_team, assignment: @assignment)
    @participant = create(:participant, assignment: @assignment)
    create(:team_user, team: @assignment_team, user: User.find(@participant.user_id))
    login_as(@participant.name)
    visit '/student_task/list'
    expect(page).to have_content 'final2'
    click_link('final2')
  end
  describe 'case 1' do
    it "Javascript should work on grades Alternate View", js: true do
      expect(page).to have_content 'Alternate View'
      expect(page).to have_content 'Review'
      click_link('Alternate View')
      expect(page).to have_content 'Grade for submission'
    end
  end
  describe 'case 2' do
    it "Student should be able to view scores", js: true do
      expect(page).to have_content 'Your scores'
      click_link('Your scores')
      expect(page).to have_content '0.00%'
    end
  end
end
