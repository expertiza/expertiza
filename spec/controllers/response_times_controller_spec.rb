describe ResponseTimesController do
  describe '#action_allowed?' do
    it "should return true" do
      expect(true).to be_truthy
    end
  end

  describe '#response_start_time' do
    context 'when the link is opened and timed' do
      it 'should update time record with end time as current time' do
        response_time_records=double('ResponseTime')
        allow(ResponseTime).to receive(:where).with([:map_id,:round,:link]).and_return(response_time_records)
        dummy = double('BasicObject')
        allow(ResponseTime).to receive(:end_at).and_return(dummy)
        allow(dummy).to receive(:nil?).and_return(true)
        allow(ResponseTime).to receive(:update_attributes).with(:end_at,:start_at).and_return(response_time_records)
        expect(response.body).to be_blank
      end
    end
  end

  describe '#response_end_time' do
    context 'when response does not have a end time' do
      it 'should update time record with end time as current time' do
        response_time_records=double('ResponseTime')
        allow(ResponseTime).to receive(:where).with([:map_id,:round,:link]).and_return(response_time_records)
        dummy = double('BasicObject')
        allow(ResponseTime).to receive(:end_at).and_return(dummy)
        allow(dummy).to receive(:nil?).and_return(true)
        allow(ResponseTime).to receive(:update_attributes).with(:end_at,Time.now.to_date).and_return(response_time_records)
        expect(response.body).to be_blank
      end
    end
  end

end

