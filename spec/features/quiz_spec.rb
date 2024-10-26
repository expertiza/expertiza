include InstructorInterfaceHelperSpec

def create_assignment_due_date
  set_deadline_type
  set_deadline_right
  create :assignment_due_date, due_at: (DateTime.now.in_time_zone + 1.day)
  @review_deadline_type = create(:deadline_type, name: 'review')
  create :assignment_due_date, due_at: (DateTime.now.in_time_zone + 1.day), deadline_type: @review_deadline_type
end

def create_default_test_data(num_qs)
  @instructor = create(:instructor)
  @student = create(:student)
  @assignment = create :assignment, require_quiz: true, instructor: @instructor, course: nil, num_quiz_items: num_qs
  create_assignment_due_date
  @team = create :assignment_team, assignment: @assignment
  @participant = create :participant, assignment: @assignment, user: @student
  create :team_user, team: @team, user: @student
  create :review_response_map, assignment: @assignment, reviewee: @team
end

def login_and_create_quiz
  login_as @student.name
  click_link 'Assignments'
  click_link @assignment.name
  click_link 'Your work'
  click_link 'Create a quiz'
end

def fill_in_choices
  fill_in 'new_choices_1_MultipleChoiceRadio_1_txt', with: 'Test Quiz 1'
  fill_in 'new_choices_1_MultipleChoiceRadio_2_txt', with: 'Test Quiz 2'
  fill_in 'new_choices_1_MultipleChoiceRadio_3_txt', with: 'Test Quiz 3'
  fill_in 'new_choices_1_MultipleChoiceRadio_4_txt', with: 'Test Quiz 4'
end

def create_choices
  [
    create(:quiz_item_choice, item: @item, txt: 'Answer 1', iscorrect: 1),
    create(:quiz_item_choice, item: @item, txt: 'Answer 2'),
    create(:quiz_item_choice, item: @item, txt: 'Answer 3'),
    create(:quiz_item_choice, item: @item, txt: 'Answer 4')
  ]
end

def create_choices_for_weighted_itemnaire(ques_id, type)
  if type == 'TrueFalse'
    [
      create(:quiz_item_choice, item: @item, txt: 'True_' + ques_id, iscorrect: 1),
      create(:quiz_item_choice, item: @item, txt: 'False_' + ques_id)
    ]
  elsif type == 'MultipleChoiceRadio'
    [
      create(:quiz_item_choice, item: @item, txt: 'Answer1_' + ques_id, iscorrect: 1),
      create(:quiz_item_choice, item: @item, txt: 'Answer2_' + ques_id),
      create(:quiz_item_choice, item: @item, txt: 'Answer3_' + ques_id),
      create(:quiz_item_choice, item: @item, txt: 'Answer4_' + ques_id)
    ]
  else
    [
      create(:quiz_item_choice, item: @item, txt: 'Answer1_' + ques_id, iscorrect: 1),
      create(:quiz_item_choice, item: @item, txt: 'Answer2_' + ques_id),
      create(:quiz_item_choice, item: @item, txt: 'Answer3_' + ques_id, iscorrect: 1),
      create(:quiz_item_choice, item: @item, txt: 'Answer4_' + ques_id)
    ]
  end
end

def fill_in_quiz
  fill_in 'itemnaire_name', with: 'Quiz for test'
  fill_in 'text_area', with: 'Test Question 1'
  page.choose('item_type_1_type_multiplechoiceradio')
  fill_in_choices
  page.choose('new_choices_1_MultipleChoiceRadio_1_iscorrect_1')
  click_on 'Create Quiz'
end

describe 'Student can create quizzes and edit them', js: true do
  before(:each) do
    create_default_test_data 1
  end

  it 'should be able to create quiz' do
    login_and_create_quiz
    fill_in_quiz
    # If the page have link View Quiz and Edit quiz, meaning the quiz has been created.
    expect(page).to have_link('View quiz')
    expect(page).to have_link('Edit quiz')
  end

  it 'should be able to view quiz after create one' do
    login_and_create_quiz
    fill_in_quiz
    click_on 'View quiz'
    expect(page).to have_content('Test Question 1')
  end

  it 'should be able to edit quiz after create one' do
    login_and_create_quiz
    fill_in_quiz
    click_on 'Edit quiz'
    expect(page).to have_content('Edit Quiz')
    fill_in 'quiz_item_choices_1_MultipleChoiceRadio_1_txt', with: 'Test Quiz 1 Edit'
    click_on 'Save quiz'
    click_on 'View quiz'
    expect(page).to have_content('Test Quiz 1 Edit')
  end

  it 'should have error message if the name of the quiz is missing' do
    login_and_create_quiz
    fill_in 'text_area', with: 'Test Question 1'
    page.choose('item_type_1_type_multiplechoiceradio')
    fill_in 'new_choices_1_MultipleChoiceRadio_1_txt', with: 'Test Quiz 1'
    fill_in 'new_choices_1_MultipleChoiceRadio_2_txt', with: 'Test Quiz 2'
    fill_in 'new_choices_1_MultipleChoiceRadio_3_txt', with: 'Test Quiz 3'
    fill_in 'new_choices_1_MultipleChoiceRadio_4_txt', with: 'Test Quiz 4'
    page.choose('new_choices_1_MultipleChoiceRadio_1_iscorrect_1')
    click_on 'Create Quiz'
    expect(page).to have_content 'Please specify quiz name (please do not use your name or id).'
  end

  it 'should have error message if The item text is missing for one or more items' do
    login_and_create_quiz
    fill_in 'itemnaire_name', with: 'Quiz for test'
    page.choose('item_type_1_type_multiplechoiceradio')
    fill_in_choices
    page.choose('new_choices_1_MultipleChoiceRadio_1_iscorrect_1')
    click_on 'Create Quiz'
    expect(page).to have_content 'Please make sure all items have text'
  end

  it 'should have error message if the choices are missing for one or more items' do
    login_and_create_quiz
    fill_in 'itemnaire_name', with: 'Quiz for test'
    fill_in 'text_area', with: 'Test Question 1'
    page.choose('item_type_1_type_multiplechoiceradio')
    # missing choice 2 and 3
    fill_in 'new_choices_1_MultipleChoiceRadio_1_txt', with: 'Test Quiz 1'
    fill_in 'new_choices_1_MultipleChoiceRadio_4_txt', with: 'Test Quiz 4'
    page.choose('new_choices_1_MultipleChoiceRadio_1_iscorrect_1')
    click_on 'Create Quiz'
    expect(page).to have_content 'Please make sure every item has text for all options'
  end

  it 'should have error message if the correct answer(s) have not been provided' do
    login_and_create_quiz
    fill_in 'itemnaire_name', with: 'Quiz for test'
    fill_in 'text_area', with: 'Test Question 1'
    page.choose('item_type_1_type_multiplechoiceradio')
    fill_in_choices
    # Save without choosing the correct answer for the quiz
    click_on 'Create Quiz'
    expect(page).to have_content 'Please select a correct answer for all items'
  end
end

describe 'multiple quiz item test', js: true do
  before(:each) do
    create_default_test_data 3
  end

  it 'number of items set matches number of quiz items avaliable' do
    # [S2] - When an assignment has a quiz there is an input field that accepts the number of items that will be on
    # each quiz. Setting this number appropriately changes the number of quiz items.
    login_and_create_quiz
    fill_in 'itemnaire_name', with: 'Quiz for test'
    expect(page).to have_content('Question 1')    # Three shall be the number thou shalt count,
    expect(page).to have_content('Question 2')    # and the number of the counting shall be three.
    expect(page).to have_content('Question 3')    # Four shalt thou not count, neither count thou two,
    expect(page).to have_no_content('Question 4') # excepting that thou then proceed to three.
    expect(page).to have_no_content('Question 5') # Five is right out.
  end
end

describe 'appropriate quiz taking times', js: true do
  before(:each) do
    @instructor = create(:instructor)
    @assignment = create :assignment, require_quiz: true, instructor: @instructor, course: nil, num_quiz_items: 1, review_topic_threshold: 1
    create_assignment_due_date
    @student1 = create(:student)
    @participant1 = create :participant, assignment: @assignment, user: @student1
    @team1 = create :assignment_team, assignment: @assignment
    create :team_user, team: @team1, user: @student1
    create :review_response_map, assignment: @assignment, reviewee: @team1
    @itemnaire = create :quiz_itemnaire, instructor_id: @team1.id
    choices = create_choices
    @item = create :quiz_item, itemnaire: @itemnaire, txt: 'Question 1', quiz_item_choices: choices
    @student2 = create(:student)
    # Create participant mapping
    @participant2 = create :participant, assignment: @assignment, user: @student2
    # Create a team linked to the calibrated assignment
    @team2 = create :assignment_team, assignment: @assignment
  end

  # [S3] - Students may not take quizzes on a phase that does not allow them to do so. When on a stage that does allow
  # for quizzes, they may take quizzes on work that they have reviewed.
  it 'should not be able to take quiz before doing review' do
    login_as @student2.name
    click_link @assignment.name
    expect(page).to have_content('Take quizzes')
    click_link 'Take quizzes'
    expect(page).to have_no_content('Request a new quiz to take')
    expect(page).to have_no_content('Quiz Questionnaire')
  end

  it 'should be able to take quiz after doing review' do
    create :team_user, team: @team2, user: @student2
    create :review_response_map, assignment: @assignment, reviewee: @team1, reviewer_id: 2
    login_as @student2.name
    click_link @assignment.name
    expect(page).to have_content('Take quizzes')
    click_link 'Take quizzes'
    expect(page).to have_no_content('Request a new quiz to take')
    expect(page).to have_content('Quiz Questionnaire')
  end
end

def create_student1
  @student1 = create(:student)
  @participant1 = create :participant, assignment: @assignment, user: @student1
end

def create_student2
  @student2 = create(:student)
  @participant2 = create :participant, assignment: @assignment, user: @student2
end

def make_team
  @team1 = create :assignment_team, assignment: @assignment
  create :team_user, team: @team1, user: @student1
  create :review_response_map, assignment: @assignment, reviewee: @team1
end

def setup_itemnaire
  @itemnaire = create :quiz_itemnaire, instructor_id: @team1.id
  choices = create_choices
  @item = create :quiz_item, itemnaire: @itemnaire, txt: 'Question 1', quiz_item_choices: choices
end

# creates quiz itemnaire and assigns weights to items
def setup_weighted_itemnaire
  @itemnaire = create :quiz_itemnaire, instructor_id: @team1.id
  choices_one = create_choices_for_weighted_itemnaire('1', 'TrueFalse')
  @item1 = create :quiz_item, itemnaire: @itemnaire, txt: 'Sample True/False Question 1?', weight: 4, quiz_item_choices: choices_one, type: 'TrueFalse'
  choices_two = create_choices_for_weighted_itemnaire('2', 'TrueFalse')
  @item2 = create :quiz_item, itemnaire: @itemnaire, txt: 'Sample True/False Question 2', weight: 2, quiz_item_choices: choices_two, type: 'TrueFalse'
  choices_three = create_choices_for_weighted_itemnaire('3', 'MultipleChoiceRadio')
  @item3 = create :quiz_item, itemnaire: @itemnaire, txt: 'Sample MultipleChoiceRadio Question 3', weight: 6, quiz_item_choices: choices_three, type: 'MultipleChoiceRadio'
  choices_four = create_choices_for_weighted_itemnaire('4', 'MultipleChoiceCheckbox')
  @item4 = create :quiz_item, itemnaire: @itemnaire, txt: 'Sample MultipleChoiceCheckbox Question 3', weight: 8, quiz_item_choices: choices_four, type: 'MultipleChoiceCheckbox'
end

def setup_responses
  @response_map = create :quiz_response_map, quiz_itemnaire: @itemnaire, reviewer: @participant2, reviewee_id: @team1.id
  @response = create :quiz_response, response_map: @response_map
  create :answer, item: @item, response_id: @response.id, answer: 1
  create :score_view, q1_id: @itemnaire.id, s_item_id: @item.id, item_weight: 1, s_score: 1, s_response_id: @response.id
end

# this creates answers using factories so that grading of quizzes can be tested
def setup_answers
  create :answer, item: @item1, response_id: @response.id, answer: 1, comments: 'True_1'
  create :answer, item: @item2, response_id: @response.id, answer: 0, comments: 'False_2'
  create :answer, item: @item3, response_id: @response.id, answer: 0, comments: 'Answer2_3'
  create :answer, item: @item4, response_id: @response.id, answer: 1, comments: 'Answer1_4'
  create :answer, item: @item4, response_id: @response.id, answer: 1, comments: 'Answer3_4'
end

# this creates score views using factories so that weighted score for quiz can be calculated
def setup_score_views
  create :score_view, q1_id: @itemnaire.id, s_item_id: @item1.id, item_weight: 4, s_score: 1, s_response_id: @response.id, s_comments: 'True_1'
  create :score_view, q1_id: @itemnaire.id, s_item_id: @item2.id, item_weight: 2, s_score: 0, s_response_id: @response.id, s_comments: 'False_2'
  create :score_view, q1_id: @itemnaire.id, s_item_id: @item3.id, item_weight: 6, s_score: 0, s_response_id: @response.id, s_comments: 'Answer2_3'
  create :score_view, q1_id: @itemnaire.id, s_item_id: @item4.id, item_weight: 8, s_score: 1, s_response_id: @response.id, s_comments: 'Answer1_4'
  create :score_view, q1_id: @itemnaire.id, s_item_id: @item4.id, item_weight: 8, s_score: 1, s_response_id: @response.id, s_comments: 'Answer3_4'
end

# this creates the set up for grading of a weighted quiz itemnaire
def setup_graded_responses
  @response = create :quiz_response, response_map: @response_map
  setup_answers
  setup_score_views
end

def init_instructor_tests
  @instructor = create(:instructor)
  @assignment = create :assignment, require_quiz: true, instructor: @instructor, course: nil, num_quiz_items: 1
  create_assignment_due_date
  create_student1
  make_team
  setup_itemnaire
  create_student2
  setup_responses
end

# Tests regarding the instructor's ability to interact with quizzes.
describe 'Instructor', js: true do
  # Setup for testing by creating the following
  #   An instructor
  #   An assignment with a 1 item quiz and a valid deadline
  #   A student, with a valid team in the assignment, that has created a quiz
  #   A second student, also in the assignment, that has completed the quiz.
  before :each do
    init_instructor_tests
  end
  # Verify that an instructor can see all quiz items,
  # answers, and scores on the review items page.
  it 'can view quiz items and scores' do
    login_as @instructor.name
    visit "/student_quizzes/review_items?id=#{@assignment.id}&type=Assignment"
    student = all('tr > td')[0]
    score = all('tr > td')[1]
    expect(student).to have_text(@student2.fullname)
    expect(score).to have_text('100.0')
    expect(page).to have_text('Average score for quiz takers: 100.0')
    expect(page).to have_text('1')
    expect(page).to have_text(@item.txt)
    expect(page).to have_text('Question Type: MultipleChoiceRadio')
    expect(page).to have_text('Answer 1')
    expect(page).to have_text('Answer 2')
    expect(page).to have_text('Answer 3')
    expect(page).to have_text('Answer 4')
    correct = find('.student_quizzes > b:nth-child(12)')
    expect(correct).to have_text('Answer 1')
  end
end

# Tests student reviewers can take the quizzes on the work they have reviewed/they need to review
describe 'Student reviewers can not take the quizzes before request artifact', js: true do
  before :each do
    @instructor = create(:instructor)
    @assignment = create :assignment, require_quiz: true, instructor: @instructor, course: nil, num_quiz_items: 1
    create_assignment_due_date
    create_student1
    make_team
    setup_itemnaire
    create_student2
  end

  it 'can not take quiz' do
    login_as @student2.name
    click_link @assignment.name
    click_link 'Take quizzes'
    expect(page).to have_no_content('Begin')
    expect(page).to have_no_content('View')
  end
end

describe 'Student reviewers can take the quizzes', js: true do
  before :each do
    @instructor = create(:instructor)
    @assignment = create :assignment, require_quiz: true, instructor: @instructor, course: nil, num_quiz_items: 1
    create_assignment_due_date
    create_student1
    make_team
    setup_itemnaire
    create_student2
    @response_map = create :quiz_response_map, quiz_itemnaire: @itemnaire, reviewer: @participant2, reviewee_id: @team1.id
  end

  it 'can take quiz' do
    login_as @student2.name
    click_link @assignment.name
    click_link 'Take quizzes'
    expect(page).to have_link('Begin')
    click_link 'Begin'
    expect(page).to have_content('Questions')
    find(:css, "input[value='Answer 1']").click
    # setting up data using factories to calculate grade
    @response = create :quiz_response, response_map: @response_map
    create :answer, item: @item, response_id: @response.id, answer: 1
    create :score_view, q1_id: @itemnaire.id, s_item_id: @item.id, item_weight: 1, s_score: 1, s_response_id: @response.id
    click_on 'Submit Quiz'
    expect(page).to have_content('Quiz score: 100.0%')
  end
end

# this creates the necessary set up so that a student reviewer can take a quiz
# and checks if weights set up during the quiz creation are taken into
# consideration when grading the quiz
describe 'Grading of quizzes takes weights into consideration', js: true do
  before :each do
    @instructor = create(:instructor)
    @assignment = create :assignment, require_quiz: true, instructor: @instructor, course: nil, num_quiz_items: 4
    create_assignment_due_date
    create_student1
    make_team
    setup_weighted_itemnaire
    create_student2
    @response_map = create :quiz_response_map, quiz_itemnaire: @itemnaire, reviewer: @participant2, reviewee_id: @team1.id
  end

  it 'can take quiz' do
    login_as @student2.name
    click_link @assignment.name
    click_link 'Take quizzes'
    expect(page).to have_link('Begin')
    click_link 'Begin'
    expect(page).to have_content('Questions')
    find(:css, "input[value='True_1']").click
    find(:css, "input[value='False_2']").click
    find(:css, "input[value='Answer2_3']").click
    find(:css, "input[value='Answer1_4']").click
    find(:css, "input[value='Answer3_4']").click
    setup_graded_responses
    click_on 'Submit Quiz'
    expect(page).to have_content('Quiz score: 60.0%')
  end
end

describe 'Student reviewers can view the quizzes they take', js: true do
  before :each do
    init_instructor_tests
  end

  it 'can view quiz' do
    login_as @student2.name
    click_link @assignment.name
    click_link 'Take quizzes'
    expect(page).to have_link('View')
    click_link 'View'
    expect(page).to have_content('Quiz score: 100.0%')
  end
end
