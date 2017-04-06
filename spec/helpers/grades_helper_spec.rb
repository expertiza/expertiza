require 'rails_helper'
require 'selenium-webdriver'

describe GradesHelper, type: :helper do
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