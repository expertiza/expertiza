describe ReviewBidsController do
  before :each do
  end

  describe "#action_allowed?" do
    context 'when different roles call the controller' do
      it "does not allow Students to run review bidding algorithm" do
        session[:user] = build(:student)
        controller.params = {action: 'assign_bidding'}
        expect(controller.action_allowed?).to be false
      end
      it "does allow Instructors, Teaching Assistants, Administrators to run review bidding algorithm" do
        controller.params = {action: 'assign_bidding'}
        session[:user] = build(:instructor)
        expect(controller.action_allowed?).to be true
        session[:user] = build(:teaching_assistant)
        expect(controller.action_allowed?).to be true
        session[:user] = build(:admin)
        expect(controller.action_allowed?).to be true
      end
      it "does allow Students to access show, index, set_priority" do
        session[:user] = build(:student)
        controller.params = {action: 'show'}
        expect(controller.action_allowed?).to be true
        controller.params = {action: 'index'}
        expect(controller.action_allowed?).to be true
        controller.params = {action: 'set_priority'}
        expect(controller.action_allowed?).to be true
      end
    end
  end


end
