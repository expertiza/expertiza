describe Bookmark do
  let(:bookmark) { Bookmark.new url: 'test.com', title: 'test bookmark', description: 'this is a test bookmark' }
  let(:bookmark1) { Bookmark.new url: 'test1.com', title: 'test1 bookmark', description: 'this is test1 bookmark' }
  let(:bookmark2) { Bookmark.new url: 'test2.com', title: 'test2 bookmark', description: 'this is test2 bookmark' }
  describe '#url' do
    it 'Validate presence of url which cannot be blank' do
      expect(bookmark).to be_valid
      bookmark.url = '  '
      expect(bookmark).not_to be_valid
    end
    it 'Validate presence of url ' do
      expect(bookmark).to be_valid
      bookmark.url = 'www.google.com'
      expect(bookmark).to be_valid
    end
  end
  describe '#title' do
    it 'Validate presence of title which cannot be blank' do
      bookmark.title = nil
      expect(bookmark).not_to be_valid
    end
  end
  describe '#title' do
    it 'Validate presence of title ' do
      bookmark.title = "Bookmark"
      expect(bookmark).to be_valid
    end
  end
  describe '#description' do
    it 'Validate presence of description which cannot be blank' do
      bookmark.description = nil
      expect(bookmark).not_to be_valid
    end
  end
  describe '#description' do
    it 'Validate presence of description ' do
      bookmark.description = 'Bookmark test'
      expect(bookmark).to be_valid
    end
  end
end