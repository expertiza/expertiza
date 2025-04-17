# frozen_string_literal: true

require 'minitest/autorun'
# test/controllers/import_file_controller_test.rb
#require 'test_helper'

describe 'ImportFileControllerSpec' do
  before do
    # Do nothing
  end

  after do
    # Do nothing
  end
end


# spec/controllers/import_file_controller_spec.rb

RSpec.describe ImportFileController, type: :controller do
  let(:file) { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/test.csv'), 'text/csv') }
  let(:base_params) do
    {
      id: 1,
      model: 'SignUpTopic',
      options: '',
      has_header: 'true',
      category: 'false',
      description: 'false',
      link: 'false',
      file: file
    }
  end

  describe '#show' do
    context 'when mentor_id is true' do
      it 'increments optional_count by 1' do
        get :show, params: base_params.merge(mentor_id: 'true')
        expect(assigns(:optional_count)).to eq(1)
      end
    end

    context 'when mentor_id is false' do
      it 'does not increment optional_count' do
        get :show, params: base_params.merge(mentor_id: 'false')
        expect(assigns(:optional_count)).to eq(0)
      end
    end
  end
end



