describe ImpersonateController do
    let(:instructor) { build(:instructor, id: 2) }
    let(:student7) { build(:student, id: 30, name: :Amanda)}

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

        it 'redirects to back' do
            allow(User).to receive(:find_by).with(name: student7.name).and_return(student7)
            request.env["HTTP_REFERER"] = "http://www.example.com"
            @params = { user: { name: student7.name } }
            get :impersonate, @params
            expect(response).to redirect_to("http://www.example.com")
        end

        it 'instructor should be able to impersonate a user with their real name' do
            allow(User).to receive(:find_by).with(name: student7.name).and_return(student7)
            allow(instructor).to receive(:can_impersonate?).with(student7).and_return(true)
            request.env["HTTP_REFERER"] = "http://www.example.com"
            @params = { user: { name: student7.name } }
            @session = { user: instructor }
            post :impersonate, @params, @session
            expect(session[:super_user]).to eq instructor
            expect(session[:user]).to eq student7
            expect(session[:original_user]).to eq instructor
            expect(session[:impersonate]).to be true
        end

        it 'instructor redirects to student home page after impersonating a student' do
            allow(User).to receive(:find_by).with(name: student7.name).and_return(student7)
            allow(instructor).to receive(:can_impersonate?).with(student7).and_return(true)
            request.env["HTTP_REFERER"] = "http://www.example.com"
            @params = { user: { name: student7.name } }
            @session = { user: instructor }
            post :impersonate, @params, @session
            expect(response).to redirect_to("/tree_display/drill")
        end

        it 'instructor should be able to impersonate a user with their anonymized name' do
            allow(User).to receive(:find_by).with(name: student7.name).and_return(student7)
            allow(instructor).to receive(:can_impersonate?).with(student7).and_return(true)
            allow(User).to receive(:anonymized_view?).and_return(true)
            allow(User).to receive(:real_user_from_anonymized_name).with("Student 30").and_return(student7)
            request.env["HTTP_REFERER"] = "http://www.example.com"
            @params = { user: { name: "Student 30" } }
            @session = { user: instructor }
            post :impersonate, @params, @session
            expect(session[:super_user]).to eq instructor
            expect(session[:user]).to eq student7
            expect(session[:original_user]).to eq instructor
            expect(session[:impersonate]).to be true
        end
    end
end