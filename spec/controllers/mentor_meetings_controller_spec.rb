describe MentorMeetingsController do
  let(:team) { create(:team) }
  let(:mentor_meeting) { create(:mentor_meeting, team: team) }

  describe '#destroy' do
    context 'when the mentor meeting exists' do
      it 'deletes the mentor meeting and redirects' do
        expect {
          delete :destroy, params: { id: mentor_meeting.id }
        }.to change(MentorMeeting, :count).by(-1)

        expect(response).to redirect_to(mentor_meetings_path)
        expect(flash[:notice]).to eq('Mentor meeting was successfully deleted.')
      end
    end

    context 'when the mentor meeting does not exist' do
      it 'returns a 404 error' do
        expect {
          delete :destroy, params: { id: -1 }
        }.not_to change(MentorMeeting, :count)

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe '#show' do
    context 'when the mentor meeting exists' do
      it 'renders the show template' do
        get :show, params: { id: mentor_meeting.id }
        expect(response).to have_http_status(:success)
        expect(assigns(:mentor_meeting)).to eq(mentor_meeting)
      end
    end

    context 'when the mentor meeting does not exist' do
      it 'returns a 404 error' do
        get :show, params: { id: -1 }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe '#index' do
    it 'assigns all mentor meetings to @mentor_meetings' do
      get :index
      expect(assigns(:mentor_meetings)).to eq([mentor_meeting])
      expect(response).to have_http_status(:success)
    end
  end

  describe '#create' do
    context 'with valid attributes' do
      it 'creates a new mentor meeting and redirects' do
        expect {
          post :create, params: { mentor_meeting: { team_id: team.id, meeting_date: Date.tomorrow } }
        }.to change(MentorMeeting, :count).by(1)

        expect(response).to redirect_to(mentor_meetings_path)
        expect(flash[:notice]).to eq('Mentor meeting was successfully created.')
      end
    end

    context 'with invalid attributes' do
      it 'does not create a new mentor meeting' do
        expect {
          post :create, params: { mentor_meeting: { team_id: nil, meeting_date: nil } }
        }.not_to change(MentorMeeting, :count)

        expect(response).to render_template(:new)
      end
    end
  end

  describe '#edit' do
    it 'renders the edit template' do
      get :edit, params: { id: mentor_meeting.id }
      expect(response).to have_http_status(:success)
      expect(assigns(:mentor_meeting)).to eq(mentor_meeting)
    end
  end

  describe '#new' do
    it 'renders the new template' do
      get :new
      expect(response).to have_http_status(:success)
      expect(assigns(:mentor_meeting)).to be_a_new(MentorMeeting)
    end
  end
  describe '#update' do
    context 'with valid attributes' do
      it 'updates the mentor meeting and redirects' do
        new_date = Date.today + 1.week
        patch :update, params: { id: mentor_meeting.id, mentor_meeting: { meeting_date: new_date } }
        mentor_meeting.reload

        expect(mentor_meeting.meeting_date).to eq(new_date)
        expect(response).to redirect_to(mentor_meetings_path)
        expect(flash[:notice]).to eq('Mentor meeting was successfully updated.')
      end
    end

    context 'with invalid attributes' do
      it 'does not update the mentor meeting' do
        patch :update, params: { id: mentor_meeting.id, mentor_meeting: { meeting_date: nil } }
        expect(response).to render_template(:edit)
      end
    end
  end

  describe '#set_mentor_meeting' do
    it 'sets the mentor meeting before actions' do
      controller.params = { id: mentor_meeting.id }
      controller.send(:set_mentor_meeting)
      expect(assigns(:mentor_meeting)).to eq(mentor_meeting)
    end
  end

  describe '#mentor_meeting_params' do
    it 'permits only allowed parameters' do
      params = ActionController::Parameters.new(mentor_meeting: { team_id: team.id, meeting_date: Date.tomorrow, invalid_param: 'hack' })
      permitted_params = controller.send(:mentor_meeting_params, params)

      expect(permitted_params.keys).to match_array(%w[team_id meeting_date])
      expect(permitted_params).not_to have_key(:invalid_param)
    end
  end
end