require 'rspec'
require 'rails_helper'
describe SuggestionController do
  describe '#add_comment' do

  it 'should do something' do
    post 'add_comment'
    @suggestioncomment = SuggestionComment.new
    #@suggestioncomment.parent_id = nil
    (@suggestioncomment.save).expect == true
    #expect(response).to receive(:get_questions_from_csv
    #true.should == false
  end
  end
  end