describe BookmarkRating do
  let(:user1) { create(:student, username: 'expertizauser', id: 1) }
  bookmark1 = nil

  before(:each) do
    bookmark1 = build(:bookmark, url: 'http://example.com', title: 'Test Bookmark', description: 'test description')
  end

  it 'can have a user and a bookmark' do
    bookmark_rating = BookmarkRating.new
    expect(bookmark_rating.user).to eq(nil)
    expect(bookmark_rating.bookmark).to eq(nil)
    bookmark_rating.user = user1
    bookmark_rating.bookmark = bookmark1
    expect(bookmark_rating.user).to eq(user1)
    expect(bookmark_rating.bookmark).to eq(bookmark1)
  end
end
