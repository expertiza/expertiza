describe Bookmark do
  bookmark = nil

  before(:each) do
    bookmark =  build(:bookmark, url: 'http://example.com', title: 'Test Bookmark', description: 'test description')
  end

  describe '#url' do
    it 'should not be blank' do
      expect(bookmark).to be_valid
      bookmark.url = ""
      expect(bookmark).not_to be_valid
    end
    it 'should not be nil' do
      expect(bookmark).to be_valid
      bookmark.url = nil
      expect(bookmark).not_to be_valid
    end
  end
  describe '#title' do
    it 'should not be blank' do
      expect(bookmark).to be_valid
      bookmark.title = ""
      expect(bookmark).not_to be_valid
    end
    it 'should not be nil' do
      expect(bookmark).to be_valid
      bookmark.title = nil
      expect(bookmark).not_to be_valid
    end
  end
  describe '#description' do
    it 'should not be blank' do
      expect(bookmark).to be_valid
      bookmark.description = ""
      expect(bookmark).not_to be_valid
    end
    it 'should not be nil' do
      expect(bookmark).to be_valid
      bookmark.description = nil
      expect(bookmark).not_to be_valid
    end
  end
end