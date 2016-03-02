require 'rails_helper'

# Test course creation functionality
describe 'Create Course' do

  # Before testing create needed state
  before :each do
    # Create the instructor account used for assignment creation
    create :instructor
  end

  # Test creating a course with calibration
  describe 'With Calibration' do

    # An assignment created with calibration turned on
    # should show the calibration tab when editing
    it 'Should show calibration tab' do
      fail 'not yet implemented'
    end
  end

  # Test creating a course without calibration
  describe 'Without Calibration' do

    # An assignment created with calibration turned off
    # should not show the calibration tab when editing
    it 'Should not show the calibration tab' do
      fail 'not yet implemented'
    end
  end
end
