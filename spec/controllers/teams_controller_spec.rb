require 'teams_helper.rb'

describe TeamsController do
  let(:superadmin) {build_stubbed(:superadmin)}
  let(:admin) {build_stubbed(:admin)}
  let(:instructor) {build_stubbed(:instructor)}
  let(:ta) {build_stubbed(:teaching_assistant)}
  let(:student) {build_stubbed(:student)}
  let(:team) {build_stubbed(:team)}
  let(:Object) {build_stubbed(:Object)}

=begin
  describe 'allow access method' do
    context 'provides access to people with' do
      it 'superadmin credentials' do
        stub_current_user(superadmin, superadmin.role.name, superadmin.role)
        expect(controller.send(:action_allowed?)).to be true
      end
      it 'admin credentials' do
        stub_current_user(admin, admin.role.name, admin.role)
        expect(controller.send(:action_allowed?)).to be true
      end
      it 'instructor credentials' do
        stub_current_user(instructor, instructor.role.name, instructor.role)
        expect(controller.send(:action_allowed?)).to be true
      end
      it 'ta credentials' do
        stub_current_user(ta, ta.role.name, ta.role)
        expect(controller.send(:action_allowed?)).to be true
      end
    end
    context 'not provides access to people with' do
      it 'student credentials' do
        stub_current_user(student, student.role.name, student.role)
        expect(controller.send(:action_allowed?)).to be false
      end
    end
  end
=end

  describe 'allow access method' do
    context 'provides access to people with' do
      it 'superadmin credentials' do
        TeamsHelper.authorizationcheck
      end
    end
  end

  describe 'create teams method' do
    context 'when everything is right' do
      it 'passes the test' do
        allow(Object).to receive_message_chain(:const_get, :find).with(any_args).and_return()
      end
    end
  end

end
