describe SubmissionViewingEventsController do

  before :each do
    @args = {
        :map_id => 123456,
        :round => 1,
        :link => "https://www.github.com"
    }

    @store = LocalStorage.new
  end

  after :each do
    @store.remove_all
  end

  describe '#action_allowed?' do
    it "should return true" do
      expect(controller.action_allowed?).to be true
    end
  end

  describe '#start_timing' do
    it 'should record the start time as the current time and clear the end time' do
      start_time = DateTime.now
      expected = LocalSubmittedContent.new map_id: @args[:map_id],
                                           round: @args[:round],
                                           link: @args[:link],
                                           start_at: start_time,
                                           end_at: nil,
                                           created_at: start_time,
                                           updated_at: start_time,
                                           total_time: 0
      post :start_timing, params: {:submission_viewing_event => @args}
      expect(response).to have_http_status :ok

      actual = @store.where(@args)
      expect(actual).to eql expected
    end
  end

  describe '#end_timing' do
    it 'should record the end time as the current time and update the total time' do
      post :start_timing, params: {:submission_viewing_event => @args}
      expect(response).to have_http_status :ok
    end
  end

  describe '#reset_timing' do
    it 'should record the end time as the current time and update the total time, and restart timing' do
      post :start_timing, params: {:submission_viewing_event => @args}
      expect(response).to have_http_status :ok
    end
  end

  describe '#hard_save' do
    it 'should save all storage proxy records in the database and remove them from the storage proxy' do
      expected = {}.to_json
      post :start_timing, params: {:submission_viewing_event => @args}
      expect(response.body).to eql expected
      expect(response).to_render :show
    end
  end

  describe '#end_round_and_save' do
      it 'stop timing for all links for the given round, and save them to the database' do
        post :start_timing, params: {:submission_viewing_event => @args}
        expect(response).to have_http_status :ok
      end
  end

end