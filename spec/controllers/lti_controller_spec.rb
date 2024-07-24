# spec/controllers/lti_controller_spec.rb
require 'rails_helper'

ENV['LTI_BASE_URL'] = 'https://expertiza.ncsu.edu/'

RSpec.describe LtiController, type: :controller do
  let(:valid_lti_params) do
    {
      'lis_person_contact_email_primary' => 'testuser@ncsu.edu',
      'other_param' => 'value'
    }
  end
  let(:invalid_lti_params) do
    {
      'lis_person_contact_email_primary' => 'testuser@invalid.com',
      'other_param' => 'value'
    }
  end
  # let(:user) { create(:user, name: 'testuser') }
  let(:user) { User.create(name: 'testuser', email: 'testuser@ncsu.edu') }
  let(:shared_secret) { 'shared_secret' }

  before do
    allow(Rails.application.secrets).to receive(:LTI_SHARED_SECRET).and_return(shared_secret)
    allow_any_instance_of(IMS::LTI::Services::MessageAuthenticator).to receive(:valid_signature?).and_return(true)
  end

  describe 'POST #launch' do
    context 'with valid LTI signature and valid domain' do
      before do
        allow(controller).to receive(:separate_email).and_return(['testuser', 'ncsu.edu'])
        allow(controller).to receive(:valid_domain?).and_return(true)
        allow(User).to receive(:find_by).and_return(user)
        allow(AuthController).to receive(:set_current_role)
        allow(ExpertizaLogger).to receive(:info)
      end

      it 'authenticates and logs in the user' do
        expect(controller).to receive(:redirect_to).with("#{ENV['LTI_BASE_URL']}/student_task/list", notice: 'Logged in successfully via LTI')
        post :launch, params: valid_lti_params
      end

      it 'redirects to the student task list' do
        expect(controller).to receive(:redirect_to).with("#{ENV['LTI_BASE_URL']}/student_task/list", notice: 'Logged in successfully via LTI')
        post :launch, params: valid_lti_params
      end
    end

    context 'with valid LTI signature and invalid domain' do
      before do
        allow(controller).to receive(:separate_email).and_return(['testuser', 'invalid.com'])
        allow(controller).to receive(:valid_domain?).and_return(false)
      end

      it 'redirects to root path with an invalid domain alert' do
        post :launch, params: invalid_lti_params
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq('Invalid domain')
      end
    end

    context 'with invalid LTI signature' do
      before do
        allow_any_instance_of(IMS::LTI::Services::MessageAuthenticator).to receive(:valid_signature?).and_return(false)
      end

      it 'redirects to root path with an invalid signature alert' do
        post :launch, params: valid_lti_params
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq('Invalid LTI signature')
      end
    end

    context 'when an error occurs' do
      before do
        allow_any_instance_of(IMS::LTI::Services::MessageAuthenticator).to receive(:valid_signature?).and_raise(StandardError.new('Test error'))
      end

      it 'logs the error and redirects to root path with an error alert' do
        expect(Rails.logger).to receive(:error).with('Error in LTI launch: Test error')
        post :launch, params: valid_lti_params
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq('An error occurred during login')
      end
    end
  end

  describe 'private methods' do
    describe '#allow_iframe' do
      it 'removes X-Frame-Options from the response headers' do
        controller.response = ActionDispatch::TestResponse.new
        controller.response.headers['X-Frame-Options'] = 'SAMEORIGIN'
        controller.send(:allow_iframe)
        expect(controller.response.headers['X-Frame-Options']).to be_nil
      end
    end

    describe '#separate_email' do
      it 'returns username and domain when email is valid' do
        result = controller.send(:separate_email, 'user@example.com')
        expect(result).to eq(['user', 'example.com'])
      end

      it 'returns nils when email is nil or empty' do
        result = controller.send(:separate_email, nil)
        expect(result).to eq([nil, nil])

        result = controller.send(:separate_email, '')
        expect(result).to eq([nil, nil])
      end

      it 'returns nils when email format is invalid' do
        result = controller.send(:separate_email, 'invalidemail')
        expect(result).to eq([nil, nil])
      end
    end

    describe '#valid_domain?' do
      it 'returns true for valid domain' do
        expect(controller.send(:valid_domain?, 'ncsu.edu')).to be_truthy
      end

      it 'returns false for invalid domain' do
        expect(controller.send(:valid_domain?, 'invalid.com')).to be_falsey
      end
    end

    describe '#authenticate_and_login_user' do
      context 'when user exists' do
        let(:user) { User.create(name: 'testuser', email: 'testuser@ncsu.edu') }
        
        before do
          allow(User).to receive(:find_by).with(name: 'testuser').and_return(user)
          allow(controller).to receive(:redirect_to)
          allow(controller).to receive(:session).and_return({})
          allow(AuthController).to receive(:set_current_role)
          allow(ExpertizaLogger).to receive(:info)
        end

        it 'sets the session user and redirects to student task list' do
          expect(controller).to receive(:redirect_to).with("#{ENV['LTI_BASE_URL']}/student_task/list", notice: 'Logged in successfully via LTI')
          controller.send(:authenticate_and_login_user, 'testuser')
          expect(controller.session[:user]).to eq(user)
        end
      end

      context 'when user does not exist' do
        before do
          allow(User).to receive(:find_by).with(name: 'testuser').and_return(nil)
          allow(controller).to receive(:redirect_to)
        end

        it 'redirects to root path with an alert' do
          expect(controller).to receive(:redirect_to).with(root_path, alert: 'User not found in Expertiza. Please register first.')
          controller.send(:authenticate_and_login_user, 'testuser')
        end
      end

      context 'when an error occurs' do
        before do
          allow(User).to receive(:find_by).with(name: 'testuser').and_raise(StandardError.new('Test error'))
          allow(controller).to receive(:redirect_to)
          allow(Rails.logger).to receive(:error)
        end

        it 'logs the error and redirects to root path with an alert' do
          expect(Rails.logger).to receive(:error).with('Error in LTI launch.authenticate_and_login: Test error')
          expect(controller).to receive(:redirect_to).with(root_path, alert: 'An error occurred during login')
          controller.send(:authenticate_and_login_user, 'testuser')
        end
      end
    end
  end
end
