require 'rspec'

describe 'Student can view review scores in a heat map distribution', js: true do

  before(:each) do
    #Include setup here for pre-test stuff

    # Create a student
    @student = create(:student)

    #Create an assignment

    #Create reviewers

    #Create reviews for the assignment from reviewers

  end

  it 'should be able to view a heat map of review scores' do
    #Log in as the student with an assignment and reviews
    login_as @student.name

    #Select the assignment and follow the link to the heat map
    click_link @assignment.name
    click_link 'Alternate View'

    expect(page).to have_content('Summary Report for Assignment')
  end

  it 'should be able to follow the link to a specific review' do
    #Log in as the student with an assignment and reviews
    login_as @student.name

    #Select the assignment and follow the link to the heat map
    click_link @assignment.name
    click_link 'Review 1'

    expect(page).to have_content('Review for')
  end

  it 'should be able to toggle the question list' do
    #Log in as the student with an assignment and reviews
    login_as @student.name

    #Select the assignment and follow the link to the heat map
    click_link @assignment.name
    click_link 'toggle question list' #Is this a link or a button or what? Make sure this works.

    expect(page).to have_content('Question')
  end

end