require './spec/support/teams_shared.rb'

describe AdvertiseForPartnerController do
  let(:student) {build_stubbed(:student)}

  include_context 'authorization check'
  context 'not provides access to people with' do
    it 'student credentials' do
      stub_current_user(student, student.role.name, student.role)
      expect(controller.send(:action_allowed?)).to be true
    end
  end

end

