describe SubmissionViewingEventsController do

  before :each do
    @args = {
      submission_viewing_event: {
        :map_id => 123456,
        :round => 1,
        :link => "https://www.github.com" }
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
      post :start_timing, @args
      expect(response).to have_http_status :ok
    end
  end

  describe '#end_timing' do
    it 'should record the end time as the current time and update the total time' do
      post :end_timing, @args
      expect(response).to have_http_status :ok
    end
  end

  describe '#reset_timing' do
    it 'should record the end time as the current time and update the total time, and restart timing' do
      post :reset_timing, @args
      expect(response).to have_http_status :ok
    end
  end

  describe '#hard_save' do
    it 'should save all storage proxy records in the database and remove them from the storage proxy' do
      post :hard_save, @args
      expect(response).to have_http_status :ok
    end
  end

  describe '#end_round_and_save' do
      it 'stop timing for all links for the given round, and save them to the database' do
        post :end_round_and_save, @args
        expect(response).to have_http_status :ok
      end
  end

end