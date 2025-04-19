# frozen_string_literal: true

require 'minitest/autorun'
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

RSpec.describe ImportFileController, type: :controller do
  let(:session) { { user: double('user', name: 'Test User', id: 1), assignment_id: 1 } }

  before do
    allow(controller).to receive(:current_user_has_ta_privileges?).and_return(true)
    # Stub SignUpTopic.import to do nothing
    allow(SignUpTopic).to receive(:import)
  end

  describe '#import_from_hash_with_headers' do
    context 'with only mentor_id as optional parameter' do
      let(:params) do
        {
          id: 1,
          model: 'SignUpTopic',
          has_header: 'true',
          optional_count: '4',  # Enabled all optional fields
          mentor_id: 'true',
          # Required header mappings
          select1: 'topic_identifier',
          select2: 'topic_name',
          select3: 'max_choosers',
          select4: 'mentor_id',
          # Simulated CSV data with mentor_id column
          contents_hash: {
            header: ['topic_identifier', 'topic_name', 'max_choosers', 'category', 'description', 'link', 'mentor_id'],
            body: [['T1', 'Sample Topic', '3', 'cat', 'desc', 'example.com', 'mentor123']]
          }.to_json
        }

      end

      it 'returns empty errors array' do
        errors = controller.send(:import_from_hash, session, params)
        expect(errors).to eq([])
      end
    end
  end
end

RSpec.describe ImportFileController, type: :controller do
  let(:session) { { user: double('user', name: 'Test User', id: 1), assignment_id: 1 } }

  before do
    allow(controller).to receive(:current_user_has_ta_privileges?).and_return(true)
    # Stub SignUpTopic.import to do nothing
    allow(SignUpTopic).to receive(:import)
  end

  describe '#import_from_hash_without_headers' do
    context 'with only mentor_id as optional parameter' do
      let(:params) do
        {
          id: 1,
          model: 'SignUpTopic',
          has_header: 'false',
          optional_count: '4',  # Enabled all optional fields
          mentor_id: 'true',
          # Required header mappings
          select1: 'topic_identifier',
          select2: 'topic_name',
          select3: 'max_choosers',
          select4: 'mentor_id',
          # Simulated CSV data with mentor_id column
          contents_hash: {
            header: ['topic_identifier', 'topic_name', 'max_choosers', 'category', 'description', 'link', 'mentor_id'],
            body: [['T1', 'Sample Topic', '3', 'cat', 'desc', 'example.com', 'mentor123']]
          }.to_json
        }

      end

      it 'returns empty errors array' do
        errors = controller.send(:import_from_hash, session, params)
        expect(errors).to eq([])
      end
    end
  end
end









