describe ReviewCommentPasteBin do
  it { should belong_to(:review_grade) }
  describe 'instance variables' do
    it 'it can be set' do
      rcpb = ReviewCommentPasteBin.new
      rcpb.title = 'title'
      rcpb.review_comment = 'comment'
    end
  end
end
