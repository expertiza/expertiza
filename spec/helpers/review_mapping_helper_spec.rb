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

     #This checks the color when a there is no update since the grading was last done
     it "should return green as new review has been graded" do
       @response.update_attribute(:is_submitted, true)
       @participant.update_attribute(:review_graded_at, Time.now)
       expect(graded_yet_color(1, 1)).to be == "green"
     end

     it "should return green as new review has been saved but not submitted" do
       expect(graded_yet_color(1, 1)).to be == "green"
     end

     it "should return red as new review has been taken but not saved" do
       expect(graded_yet_color(1, 2)).to be == "red"
     end

     it "should return green as no grading has been done yet" do
       @response.update_attribute(:is_submitted, true)
       @participant.update_attribute(:review_graded_at, nil)
       expect(graded_yet_color(1, 1)).to be == "green"
     end


   end


end
