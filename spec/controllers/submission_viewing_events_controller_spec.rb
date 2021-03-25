describe SubmissionViewingEventsController do

  let(:github_timing) {
    build(
      :submission_viewing_event,
      map_id: 123456,
      round: 1,
      link: "https://www.github.com",
      start_at: DateTime(2021, 03, 25, 00, 15, 00),
      end_at: DateTime(2021, 03, 25, 00, 20, 00),
      total_time: 300
    )
  }

  let(:readme_timing) {
    build(
      :submission_viewing_event,
      map_id: 123456,
      round: 1,
      link: "README.md",
      start_at: DateTime(2021, 03, 25, 00, 20, 00),
      end_at: DateTime(2021, 03, 25, 00, 30, 00),
      total_time: 600
    )
  }

  before :all do
    @args_without_link = {
      :map_id => 123456,
      :round => 1
    }

    @args_with_link = @args_without_link.merge :link => "https://www.github.com"
    @args_with_link_2 = @args_without_link.merge :link => "https://www.google.com"
    @args_with_link_3 = @args_without_link.merge :link => "https://www.example.com"

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
    it 'should record the start time as the current time and clear the end time for the given link' do
      post :start_timing, paramify(@args_with_link)
      expect(response).to have_http_status :ok
    end

    it 'should record the start time as the current time and clear the end time for all links for a given round' do
      post :start_timing, paramify(@args_without_link)
      expect(response).to have_http_status :ok
    end
  end

  describe '#end_timing' do
    it 'should record the end time as the current time and update the total time' do
      post :end_timing, paramify(@args_with_link)
      expect(response).to have_http_status :ok
    end

    it 'should record the end time as the current time and update the total time for all links in a given round' do
      post :end_timing, paramify(@args_without_link)
      expect(response).to have_http_status :ok
    end
  end

  describe '#reset_timing' do
    it 'should record the end time as the current time, update the total time, and restart timing' do
      # no need to test this response, as it's already tested
      post :start_timing, paramify(@args_with_link)
      post :reset_timing, paramify(@args_with_link)
      expect(response).to have_http_status :ok
    end

    it 'should record the end time as the current time, update the total time, and restart timing for all links in a given round' do
      to_post = [
        @args_with_link,
        @args_with_link_2,
        @args_with_link_3
      ]

      # start timing each one
      to_post.each { |it| post :start_timing, paramify(it)}

      post :reset_timing, paramify(@args_without_link)
      expect(response).to have_http_status :ok
    end
  end

  describe '#hard_save' do
    it 'should save all storage proxy records in the database and remove them from the storage proxy' do
      to_post = [
        @args_with_link,
        @args_with_link_2,
        @args_with_link_3
      ]

      # start timing each one
      to_post.each { |it| post :start_timing, paramify(it)}

      post :end_timing, paramify(@args_without_link)

      expected = to_post.map { |it| it[:link] }.to_json

      post :hard_save, paramify(@args_with_link)

      expect(response.body).to eql expected
    end
  end

  describe '#end_round_and_save' do
      it 'stop timing for all links for the given round, and save them to the database' do
        post :end_round_and_save, paramify(@args_with_link)
        expect(response).to have_http_status :ok
      end
  end

  describe '#getTimingDetails' do
    it 'should return timing details from the database' do
      allow(SubmissionViewingEvent).to receive(:where).with(123456, 1).and_return([github_timing, readme_timing])
      post :getTimingDetails
      expect(response.body).not_to be_nil
    end
  end

  private

  def paramify(args)
    {submission_viewing_event: args}
  end
  
end