include InstructorInterfaceHelperSpec

question_type = %w[Criterion Scale Dropdown Checkbox TextArea TextField UploadFile SectionHeader TableHeader ColumnHeader]

describe 'Questionnaire tests for instructor interface' do
  before(:each) do
    assignment_setup
  end
  describe 'Instructor login' do
    it 'with valid username and password' do
      login_as('instructor6')
      visit '/tree_display/list'
      expect(page).to have_content('Manage content')
    end

    it 'with invalid username and password' do
      visit root_path
      fill_in 'login_username', with: 'instructor6'
      fill_in 'login_password', with: 'something'
      click_button 'Sign in'
      expect(page).to have_text('Your username or password is incorrect.')
    end
  end

  def make_questionnaire(private)
    login_as('instructor6')
    visit '/questionnaires/new?model=ReviewQuestionnaire&private=' + (private ? '1' : '0')
    fill_in('questionnaire_name', with: 'Review 1')
    fill_in('questionnaire_min_question_score', with: '0')
    fill_in('questionnaire_max_question_score', with: '5')
    select(private ? 'yes' : 'no', from: 'questionnaire_private')
    click_button 'Create'
  end

  describe 'Create a public review questionnaire' do
    it 'is able to create a public review questionnaire' do
      make_questionnaire false
      expect(Questionnaire.where(name: 'Review 1')).to exist
    end
  end

  describe 'Create a private review questionnaire' do
    it 'is able to create a private review questionnaire' do
      make_questionnaire true
      expect(Questionnaire.where(name: 'Review 1')).to exist
    end
  end

  def load_questionnaire
    login_as('instructor6')
    visit '/questionnaires/new?model=ReviewQuestionnaire&private=0'
    fill_in('questionnaire_name', with: 'Review n')
    fill_in('questionnaire_min_question_score', with: '0')
    fill_in('questionnaire_max_question_score', with: '5')
    select('no', from: 'questionnaire_private')
    click_button 'Create'
  end

  def load_question(question_type)
    load_questionnaire
    fill_in('question_total_num', with: '1')
    select(question_type, from: 'question_type')
    click_button 'Add'
  end

  describe 'Create a review question' do
    question_type.each do |q_type|
      it 'is able to create ' + q_type + ' question' do
        load_question q_type
        expect(page).to have_content('Remove')
        click_button 'Save review questionnaire'
        expect(page).to have_content('All questions have been successfully saved!')
      end
    end
  end

  def edit_created_question
    first("textarea[placeholder='Edit question content here']").set 'Question edit'
    click_button 'Save review questionnaire'
    expect(page).to have_content('All questions have been successfully saved!')
    expect(page).to have_content('Question edit')
  end

  def check_deleted_question
    click_on('Remove')
    expect(page).to have_content('You have successfully deleted the question!')
  end

  def choose_check_type(command_type)
    if command_type == 'edit'
      edit_created_question
    else
      check_deleted_question
    end
  end

  describe 'Edit and delete a question' do
    question_type.each do |q_type|
      %w[edit delete].each do |q_command|
        it 'is able to ' + q_command + ' ' + q_type + ' question' do
          load_question q_type
          choose_check_type q_command
        end
      end
    end
  end

  describe 'Edit a review advice' do
    it 'is able to edit a public review advice' do
      # create review advice
      load_question 'Criterion'
      click_button 'Edit/View advice'
      expect(page).to have_content('Edit an existing questionnaire')
      first(:css, "textarea[id^='horizontal_'][id$='advice']").set('Advice 1')
      click_button 'Save and redisplay advice'
      expect(page).to have_content('advice was successfully saved')
      expect(page).to have_content('Advice 1')
      # edit review advice
      first(:css, "textarea[id^='horizontal_'][id$='advice']").set('Advice edit')
      click_button 'Save and redisplay advice'
      expect(page).to have_content('advice was successfully saved')
      expect(page).to have_content('Advice edit')
    end
  end
end
