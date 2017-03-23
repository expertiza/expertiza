require 'rspec'

describe 'Student can view review scores in a heat map distribution', js: true do

  before(:each) do
    # Include setup here for pre-test stuff

    # Create a student
    @student = create(:student)

    # Create an instructor
    @instructor = create(:instructor)

    # Create an assignment
    @assignment = create :assignment, instructor: @instructor, course: nil, num_quiz_questions: 1

    # Create reviewers

    # Create reviews for the assignment from reviewers
    # I'm not quite sure what the best way is to set these up. Do I need to make actual reviewers? Which factory type
    # makes the reviews I need to display in the heat map?

  end

  it 'should show an empty table with no reviews' do
    # Log in as the student with an assignment and reviews
    login_as @student.name
    expect(page).to_not have_content('Review 1')
  end

  it 'should be able to sort by total review score' do
    # This would require us to create several reviews 
  end

  it 'should be able to view a heat map of review scores' do
    # Log in as the student with an assignment and reviews
    login_as @student.name

    # Select the assignment and follow the link to the heat map
    click_link @assignment.name
    click_link 'Alternate View'

    expect(page).to have_content('Summary Report for assignment')
  end

  it 'should be able to follow the link to a specific review' do
    # Log in as the student with an assignment and reviews
    login_as @student.name

    # Select the assignment and follow the link to the heat map
    click_link @assignment.name
    click_link 'Review 1'

    expect(page).to have_content('Review for')
  end

  it 'should be able to toggle the question list' do
    # Log in as the student with an assignment and reviews
    login_as @student.name

    # Select the assignment and follow the link to the heat map
    click_link @assignment.name
    click_link 'toggle question list' # This is a link

    expect(page).to have_content('Question')
  end

end
