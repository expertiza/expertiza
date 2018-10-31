require 'rspec'
require 'spec_helper'
RSpec.describe AdminController, type: :controller do
  describe 'Delete Instructor' do
    let(:admin) { build(:admin, id: 3) }
    let(:super_admin) { build :superadmin }
    let(:instructor) { build(:instructor, id: 2) }
    let(:student1) { build(:student, id: 1, name: :lily) }
    let(:student2) { build(:student) }
    let(:student3) { build(:student, id: 10, role_id: 1, parent_id: nil) }
    let(:student4) { build(:student, id: 20, role_id: 4) }
    let(:student5) { build(:student, role_id: 4, parent_id: 3) }
    let(:student6) { build(:student, role_id: nil, name: :lilith) }

    let(:institution1) { build(:institution, id: 1) }
    let(:requested_user1) { RequestedUser.new id: 4, name: 'requester1', role_id: 2, fullname: 're, requester1',
                                             institution_id: 1, email: 'requester1@test.com', status: nil, self_introduction: 'no one' }
    let(:superadmin) { build :superadmin }
    let(:assignment) { build(:assignment, id: 1, name: "test_assignment", instructor_id: 2,
                            participants: [build(:participant, id: 1, user_id: 1, assignment: assignment)], course_id: 1) }
    before(:each) do
      stub_current_user(instructor, instructor.role.name, instructor.role)
    end
    include Capybara::DSL
    it 'delete instructor successfully' do
      # visit show_instructor_admin_index_path
      allow(User).to receive(:find).with('2').and_return(instructor)
      @params = {id: 2}
      post :remove_instructor, @params
      expect(flash[:error]).not_to be_nil
    end
    it 'delete admin successfully' do
      # visit show_instructor_admin_index_path
      allow(User).to receive(:find).with('3').and_return(admin)
      @params = {id: 3}
      post :remove_administrator, @params
      expect(flash[:error]).not_to be_nil
    end
  end
end
