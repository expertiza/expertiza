include InstructorInterfaceHelperSpec

item_type = %w[Criterion Scale Dropdown Checkbox TextArea TextField UploadFile SectionHeader TableHeader ColumnHeader]

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
      fill_in 'login_name', with: 'instructor6'
      fill_in 'login_password', with: 'something'
      click_button 'Sign in'
      expect(page).to have_text('Your username or password is incorrect.')
    end
  end

  def make_itemnaire(private)
    login_as('instructor6')
    visit '/itemnaires/new?model=ReviewQuestionnaire&private=' + (private ? '1' : '0')
    fill_in('itemnaire_name', with: 'Review 1')
    fill_in('itemnaire_min_item_score', with: '0')
    fill_in('itemnaire_max_item_score', with: '5')
    select(private ? 'yes' : 'no', from: 'itemnaire_private')
    click_button 'Create'
  end

  describe 'Create a public review itemnaire' do
    it 'is able to create a public review itemnaire' do
      make_itemnaire false
      expect(Questionnaire.where(name: 'Review 1')).to exist
    end
  end

  describe 'Create a private review itemnaire' do
    it 'is able to create a private review itemnaire' do
      make_itemnaire true
      expect(Questionnaire.where(name: 'Review 1')).to exist
    end
  end

  def load_itemnaire
    login_as('instructor6')
    visit '/itemnaires/new?model=ReviewQuestionnaire&private=0'
    fill_in('itemnaire_name', with: 'Review n')
    fill_in('itemnaire_min_item_score', with: '0')
    fill_in('itemnaire_max_item_score', with: '5')
    select('no', from: 'itemnaire_private')
    click_button 'Create'
  end

  def load_item(item_type)
    load_itemnaire
    fill_in('item_total_num', with: '1')
    select(item_type, from: 'item_type')
    click_button 'Add'
  end

  describe 'Create a review item' do
    item_type.each do |q_type|
      it 'is able to create ' + q_type + ' item' do
        load_item q_type
        expect(page).to have_content('Remove')
        click_button 'Save review itemnaire'
        expect(page).to have_content('All items have been successfully saved!')
      end
    end
  end

  def edit_created_item
    first("textarea[placeholder='Edit item content here']").set 'Question edit'
    click_button 'Save review itemnaire'
    expect(page).to have_content('All items have been successfully saved!')
    expect(page).to have_content('Question edit')
  end

  def check_deleted_item
    click_on('Remove')
    expect(page).to have_content('You have successfully deleted the item!')
  end

  def choose_check_type(command_type)
    if command_type == 'edit'
      edit_created_item
    else
      check_deleted_item
    end
  end

  describe 'Edit and delete a item' do
    item_type.each do |q_type|
      %w[edit delete].each do |q_command|
        it 'is able to ' + q_command + ' ' + q_type + ' item' do
          load_item q_type
          choose_check_type q_command
        end
      end
    end
  end

  describe 'Edit a review advice' do
    it 'is able to edit a public review advice' do
      # create review advice
      load_item 'Criterion'
      click_button 'Edit/View advice'
      expect(page).to have_content('Edit an existing itemnaire')
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
