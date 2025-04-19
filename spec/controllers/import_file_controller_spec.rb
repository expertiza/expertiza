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
require 'rails_helper'

RSpec.describe ImportFileController, type: :controller do
  let(:file) do
    fixture_file_upload(Rails.root.join('spec/fixtures/files/test.csv'), 'text/csv')
  end

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

  before do
    allow(controller).to receive(:current_user_has_ta_privileges?).and_return(true)
    allow(controller).to receive(:get_delimiter).and_return(',')
    allow(controller).to receive(:parse_to_grid).and_return([["header1", "header2"], ["value1", "value2"]])
    allow(controller).to receive(:parse_to_hash).and_return([{"header1" => "value1", "header2" => "value2"}])
  end

  describe '#show' do
    context 'when mentor_id is true' do
      it 'increments optional_count by 1' do
        post :show, params: base_params.merge(mentor_id: 'true')
        expect(controller.instance_variable_get(:@optional_count)).to eq(1)
      end
    end

    context 'when mentor_id is false' do
      it 'does not increment optional_count' do
        post :show, params: base_params.merge(mentor_id: 'false')
        expect(controller.instance_variable_get(:@optional_count)).to eq(0)
      end
    end
  end
end







