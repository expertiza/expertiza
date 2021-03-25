describe LocalSubmittedContent do
  #tests LocalSubmittedContent.new() successfully creates entry
  describe '#initialize' do
    it 'should create object using specified params' do
      content = LocalSubmittedContent.new(map_id: 1, round: 2, link: "http://google.com",start_at: "2017-12-05 19:11:52", end_at: "2017-12-05 20:11:52" )
      expect(content.map_id).to eq(1)
      expect(content.round).to eq(2)
      expect(content.link).to eq("http://google.com")
      expect(content.start_at).to eq("2017-12-05 19:11:52")
      expect(content.end_at).to eq("2017-12-05 20:11:52")
    end
  end

  describe '#to_h'do
    it 'should convert the object to hash representation' do
      content = LocalSubmittedContent.new(map_id: 1, round: 2, link: "http://google.com",start_at: "2017-12-05 19:11:52", end_at: "2017-12-05 20:11:52" )
      hash_representation = {:map_id=>1, :round=>2, :link=>"http://google.com", :start_at=>"2017-12-05 19:11:52", :end_at=>"2017-12-05 20:11:52", :created_at=>nil, :updated_at=>nil, :total_time=>0}

      expect(content.to_h()).to eq(hash_representation)
    end
  end

  describe '#=='do
    it 'should compare two content objects' do
      content = LocalSubmittedContent.new(map_id: 1, round: 2, link: "http://google.com",start_at: "2017-12-05 19:11:52", end_at: "2017-12-05 20:11:52" )
      expect(content == content).to eq(true)
    end
  end
end