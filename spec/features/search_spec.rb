# spec/features/search_spec.rb

require 'rails_helper'

RSpec.feature 'Search functionality', type: :feature, js: true do
  before do
    # Assuming you have some setup code here, e.g., creating test data
    # or navigating to the page where the search functionality is present
  end

  scenario 'User can search for a student' do
    visit '/assessment360/all_students_all_reviews?course_id=243'

    # Assuming you have some code here to wait for the JavaScript to load
    # If you are using a single-page application framework, you might need
    # to wait for specific elements to be present or visible

    # Type the search query in the input field
    fill_in 'studentSearch', with: 'student9163'  # Replace 'John Doe' with a valid student name

    # Optionally, you can add some waiting time if necessary
    # sleep 1

    # Check if the table rows are updated according to the search query
    expect(page).to have_css('table#myTable tr', count: expected_row_count)

    # You can add more specific expectations based on your JavaScript logic
    # For example, you might want to check if certain rows are visible or hidden
    expect(page).to have_css('table#myTable tr:visible', text: 'student9163')

    # Add more expectations as needed based on your specific JavaScript logic
  end
end