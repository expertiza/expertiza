
describe 'student_task/list.html.erb' do
  let(:assignment) { build(:assignment, id: 1, name: 'no assignment', participants: [participant], teams: [team]) }
  let(:course) { build(:course) }
  let(:topic) { build(:topic)}
  # let(:current)
  let(:participant) { build(:participant, id: 1) }
  let(:submission_grade) { build(:review_grade)}
  let(:badge) {build(:badge)}

  describe ''
    # render
    #
    # rendered.should contain('Shirt')
    # rendered.should contain('50.0')
  # end
end