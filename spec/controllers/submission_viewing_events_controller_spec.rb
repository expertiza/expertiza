describe SubmissionViewingEventsController do

  before :each do
    args = {
      submission_viewing_event: {
        :map_id => 123456,
        :round => 1,
        :link => "https://www.github.com" }
    }
  end

  describe '#action_allowed?' do
    it "should return true" do
      expect(controller.action_allowed?).to be true
    end
  end

  describe '#start_timing' do
    context 'when the link is opened' do
      it 'should record the start time as the current time and clear the end time' do
        expect(controller.start_timing(args)).to have_http_status :ok
      end
    end
  end

  describe '#end_timing' do
    context 'when a tab is closed' do
      it 'should record the end time as the current time and update the total time' do
        expect(controller.end_timing(args)).to have_http_status :ok
      end
    end
    end

  describe '#reset_timing' do
    context 'when a reivew is saved or submitted' do
      it 'should record the end time as the current time and update the total time, and restart timing' do
        expect(controller.reset_timing(args)).to have_http_status :ok
      end
    end
  end

  describe '#hard_save' do
    context 'when explicitly requested to' do
      it 'should save all storage proxy records in the database and remove them from the storage proxy' do
        expect(controller.hard_save(args)).to have_http_status :ok
      end
    end
  end

  describe '#end_round_and_save' do
    context 'when explicitly requested to' do
      it 'stop timing for all links for the given round, and save them to the database' do
        expect(controller.end_round_and_save(args)).to have_http_status :ok
      end
    end
  end

end