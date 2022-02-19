describe Bookmark do
  bookmark = nil

  before(:each) do
    bookmark =  build(:bookmark, url: 'http://example.com', title: 'Test Bookmark', description: 'test description')
  end

  describe '#url' do
    it 'should not be blank' do
      bookmark.url = ''
      expect(bookmark).not_to be_valid
    end
    it 'should not be nil' do
      bookmark.url = nil
      expect(bookmark).not_to be_valid
    end
  end
  describe '#title' do
    it 'should not be blank' do
      bookmark.title = ''
      expect(bookmark).not_to be_valid
    end
    it 'should not be nil' do
      bookmark.title = nil
      expect(bookmark).not_to be_valid
    end
  end
  describe '#description' do
    it 'should not be blank' do
      bookmark.description = ''
      expect(bookmark).not_to be_valid
    end
    it 'should not be nil' do
      bookmark.description = nil
      expect(bookmark).not_to be_valid
    end
  end
end
