include InstructorInterfaceHelperSpec
#E1992 - adding cake type question to questionnaire to check if questionnaire gets saved
question_type = %w[Criterion Scale Dropdown Checkbox TextArea TextField Cake]
#define the type of questions to be added to mock questionnaire
describe "Testing cake type question functionality" do

  describe "Test Questionnaire creation and add Cake type question in questionnaire for instructor6" do
  before(:each) do
    assignment_setup     #use method from InstructorInterfaceHelperSpec
  end
  describe "Instructor login" do
    it "with valid username and password" do
      login_as("instructor6")
      visit '/tree_display/list'
      expect(page).to have_content("Manage content")
    end

    it "with invalid username and password" do
      visit root_path
      fill_in 'login_name', with: 'instructor6'
      fill_in 'login_password', with: 'something'
      click_button 'Sign in'
      expect(page).to have_text('Your username or password is incorrect.')
    end
  end

  describe "Create a public review questionnaire" do
    it "is able to create a public review questionnaire" do
      make_questionnaire false
      expect(Questionnaire.where(name: "Review 1")).to exist
    end
  end
  describe "Create a review question" do
    question_type.each do |q_type|
      it "is able to create " + q_type + " question" do       #iterate over each question type and add question to questionnaire
        load_question q_type
        expect(page).to have_content('Remove')
        click_button "Save review questionnaire"
        expect(page).to have_content('The questionnaire has been successfully updated!')
        #Expect a flash message with content written above
      end
    end
  end

  def load_question question_type
    load_questionnaire
    fill_in('new_question_total_num', with: '1')  #The id is changed to new_XXXX for both, and has to be overridden in the previous capybara tests written too!
    select(question_type, from: 'new_question_type')
    click_button "Add"
  end

  def load_questionnaire
    login_as("instructor6")
    visit '/questionnaires/new?model=ReviewQuestionnaire&private=0'
    fill_in('questionnaire_name', with: 'Review n')
    fill_in('questionnaire_min_question_score', with: '0')
    fill_in('questionnaire_max_question_score', with: '5')
    select('no', from: 'questionnaire_private')
    click_button "Create"
  end

  def make_questionnaire private
    login_as("instructor6")
    visit '/questionnaires/new?model=ReviewQuestionnaire&private=' + (private ? '1' : '0')
    fill_in('questionnaire_name', with: 'Review 1')
    fill_in('questionnaire_min_question_score', with: '0')
    fill_in('questionnaire_max_question_score', with: '5')
    select(private ? 'yes' : 'no', from: 'questionnaire_private')
    click_button "Create"
  end
  end
end