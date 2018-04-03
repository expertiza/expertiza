describe 'Assignment topic table', js:true do

  context 'assignment due dates have not passed' do
    # before(:each) do
    #   due_date.due_at = DateTime.now.in_time_zone + 1.day
    #   allow(assignment.due_dates).to receive(:find_by).with(deadline_type_id: 6).and_return(due_date)
    # end
    it 'allows a topic to be edited' do
      login_as('instructor6')
      visit "/assignments/1/edit"
      click_button 'Topics'
      wait_for_ajax
      expect(page).to respond_to(:edit)
      #params = {id: 1, anchor: 'tabs-2'}
      #get :edit, params, xhr: true
      #expect(response).to respond_to(:edit)
    end

    it 'allows a topic to be deleted' do
      params = {id: 1, anchor: 'tabs-2'}
      get :edit, params, xhr: true
      expect(response).to respond_to(:destroy)
    end

    it 'allows a new topic to be added' do
      params = {id: 1, anchor: 'tabs-2'}
      get :edit, params, xhr: true
      expect(response).to respond_to(:new)
    end
  end

  context 'all assignment due dates have passed' do
    before(:each) do
      due_date.due_at = DateTime.now.in_time_zone - 1.day
      allow(assignment.due_dates).to receive(:find_by).with(deadline_type_id: 6).and_return(due_date)
    end
    it 'does not allow a topic to be edited' do
      params = {id: 1, anchor: 'tabs-2'}
      get :edit, params, xhr: true
      expect(response).not_to respond_to(:edit)
    end

    it 'does not allow a topic to be deleted' do
      params = {id: 1, anchor: 'tabs-2'}
      get :edit, params, xhr: true
      expect(response).not_to respond_to(:destroy)
    end

    it 'does not allow a new topic to be added' do
      params = {id: 1, anchor: '#tabs-2'}
      get :edit, params
      expect(response).to render_template(:partial => 'sign_up_topics/add_signup_topics')
      expect(response).not_to respond_to(:new)
    end
  end

  # context 'team has ad', js: true do
  #   it 'displays the ad horn in the manage topics table' do
  #     login_as('instructor6')
  #     visit "/assignments/1/edit#tabs-2"
  #     @team = Team.new(id: 1, advertise_for_partner: 1)
  #     @signed_up_team = SignedUpTeam.new(id: 1, topic_id: 1)
  #     allow(SignUpTopic).to receive(:find).with('1').and_return(topic)
  #     # params = {id: 1}
  #     # get :edit, params, xhr: true, with: '/#tabs-2'
  #     # expect(response).to have_css('img', text: 'ad_horn.png')
  #     expect(response).to have_content("ad_horn.png")
  #   end
  # end
end