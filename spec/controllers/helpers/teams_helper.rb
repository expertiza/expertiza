RSpec.configure do |rspec|
  rspec.shared_context_metadata_behavior = :apply_to_host_groups
end

RSpec.shared_context 'allow access method', :shared_context => :metadata do
  before {
    let(:superadmin) {build_stubbed(:superadmin)}
    let(:admin) {build_stubbed(:admin)}
    let(:instructor) {build_stubbed(:instructor)}
    let(:ta) {build_stubbed(:teaching_assistant)}
    let(:student) {build_stubbed(:student)}
    let(:team) {build_stubbed(:team)}
  }
  def authorizationcheck
    it '' do

    end
  end
end





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
      it 'student credentials' do
        stub_current_user(student, student.role.name, student.role)
        expect(controller.send(:action_allowed?)).to be false
      end


RSpec.configure do |rspec|
  rspec.include_context 'allow access method', :include_shared => true
end