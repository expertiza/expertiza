RSpec.configure do |rspec|
  rspec.shared_context_metadata_behavior = :apply_to_host_groups
end

shared_context 'authorization check', :shared_context => :metadata do
    let(:superadmin) {build_stubbed(:superadmin)}
    let(:admin) {build_stubbed(:admin)}
    let(:instructor) {build_stubbed(:instructor)}
    let(:ta) {build_stubbed(:teaching_assistant)}
    let(:student) {build_stubbed(:student)}

    it 'superadmin credentials' do
      stub_current_user(superadmin, superadmin.role.name, superadmin.role)
      expect(controller.send(:action_allowed?)).to be true
    end
    it 'admin credentials' do
      stub_current_user(admin, admin.role.name, admin.role)
      expect(controller.send(:action_allowed?)).to be true
    end
    it 'ta credentials' do
      stub_current_user(ta, ta.role.name, ta.role)
      expect(controller.send(:action_allowed?)).to be true
    end
    it 'instructor credentials' do
      stub_current_user(instructor, instructor.role.name, instructor.role)
      expect(controller.send(:action_allowed?)).to be true
    end
end
