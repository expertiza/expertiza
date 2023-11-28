describe 'Search functionality' do
    before do
      # Create necessary records using FactoryBot
      @course = create(:course)
      @student = create(:student)
      @assignment = create(:assignment, course: @course)
      @course_participant = create(:course_participant, user: @student, course: @course)
    end
  
    it 'filters students based on search input', js: true do

      login_as('instructor6')
  
      # Visit the page where the search functionality is implemented
      visit "/assessment360/all_students_all_reviews?course_id=#{@course.id}"
  
      # Perform a search with a known student name
      fill_in 'studentSearch', with: @student.fullname
      # Add other necessary steps for triggering the search
  
      # Validate that the displayed table only contains the searched student's information
      page.all('#myTable tr').each do |tr|
        expect(tr).to have_content?(@student.fullname)
      end
    end
  end