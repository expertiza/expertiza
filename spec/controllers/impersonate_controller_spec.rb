describe ImpersonateController do
    let(:instructor) { build(:instructor, id: 2) }
    let(:student7) { build(:student, id: 30, name: :amanda)}

    # impersonate is mostly used by instructors 
    # run all tests using instructor account
    # except some exceptions where we'll use other accounts
    before(:each) do
        stub_current_user(instructor, instructor.role.name, instructor.role)
    end

    context "#impersonate" do
        it 'when instructor tries to impersonate another user' do 
            expect(controller.action_allowed?).to be true
        end

        it 'when student tries to impersonate another user' do
            stub_current_user(student7, student7.role.name, student7.role)
            expect(controller.action_allowed?).to be false
        end
    end
end