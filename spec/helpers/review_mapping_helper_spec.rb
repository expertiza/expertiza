require 'rails_helper'
require './app/helpers/review_mapping_helper.rb'

RSpec.configure do |c|
  c.include ReviewMappingHelper
end

# For this rspec, we use the create method in place of the build method as the method being
# tested directly hits the Database

describe "ReviewMappingHelper" do
  before(:each) do
    @participant = create(:participant)
    @response = create(:response)
     end

   describe "#check_correct_color" do

     #This checks the color when a new review is entered after grading has been done
     it "should return blue as new review has been submitted and not graded" do
       @response.update_attribute(:is_submitted, true)
       expect(graded_yet_color(1, 1)).to be == "blue"
     end


   end


end
