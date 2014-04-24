require 'rspec'
require 'spec_helper'

describe 'ReviewMappingController' do
describe 'ReviewReport' do
   it 'returns a response map array' do
     expect(@reviewers)
   end
   it 'gets a type from view'do
     expect(@type)
   end
   it 'the type received should be a String' do
   expect(@type.instance_of?String)
   end
   it 'returns review scores array' do
     expect(@review_scores)
   end
end
end