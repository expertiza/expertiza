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


RSpec.describe ImportFileController, type: :controller do
  let(:file_content) { "header1,header2\nvalue1,value2" }
  let(:file) do
    # Create a file-like object that responds to read
    file = double('file')
    allow(file).to receive(:read).and_return(file_content)
    file
  end

  # Mock necessary helper methods
  before do
    allow(controller).to receive(:get_delimiter).and_return(',')
    allow(controller).to receive(:parse_to_grid).and_return([["header1", "header2"], ["value1", "value2"]])
    allow(controller).to receive(:parse_to_hash).and_return([{"header1" => "value1", "header2" => "value2"}])
  end

  describe '#show' do
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

    context 'when mentor_id is true' do
      it 'increments optional_count by 1' do
        get :show, params: base_params.merge(mentor_id: 'true')

        # For debugging, directly check instance variables if assigns fails
        if assigns(:optional_count).nil?
          puts "DEBUG: @model = #{controller.instance_variable_get(:@model)}"
          puts "DEBUG: actual @optional_count = #{controller.instance_variable_get(:@optional_count)}"
        end

        expect(controller.instance_variable_get(:@optional_count)).to eq(1)
      end
    end

    context 'when mentor_id is false' do
      it 'does not increment optional_count' do
        get :show, params: base_params.merge(mentor_id: 'false')
        expect(controller.instance_variable_get(:@optional_count)).to eq(0)
      end
    end
  end
end





