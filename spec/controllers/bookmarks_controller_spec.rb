require 'spec_helper'
require 'rails_helper'

describe BookmarksController do
  render_views

  let(:assignment) do
    build(:assignment, id: 1, name: 'test assignment', instructor_id: 6, staggered_deadline: true,
                       participants: [build(:participant)], teams: [build(:assignment_team)],
                       course_id: 1)
  end
  let(:assignment_form) { double('AssignmentForm', assignment: assignment) }
  let(:admin) { build(:admin) }
  let(:instructor) { build(:instructor, id: 6) }
  let(:instructor2) { build(:instructor, id: 66) }
  let(:ta) { build(:teaching_assistant, id: 8) }
  let(:student) { build(:student, id: 42) }
  let(:topic) { build(:topic) }
  let(:bookmark) { build(:bookmark) }

  before(:each) do
    allow(Assignment).to receive(:find).with('1').and_return(assignment)
    allow(SignUpTopic).to receive(:find).with('1').and_return(topic)
    allow(Bookmark).to receive(:where).and_return([bookmark])
    allow(Bookmark).to receive(:where).and_return([bookmark])
    @session = {user: student}
    stub_current_user(student, student.role.name, student.role)
  end

  describe '#list' do
    context 'when student requests for bookmarks' do
      it 'should show bookmarks' do
        params = {id: '1'}
        get :list, params, @session
        expect(controller.instance_variable_get(:@bookmarks).size).to eq(1)
        expect(controller.instance_variable_get(:@topic).topic_name).to eq('Hello world!')
        expect(response.body).to include '<td>This is a test topic</td>'
        expect(response.body).to include '<td><a href=http://test.com target=\'_blank\'>Test</td>'
      end
    end
  end
end
