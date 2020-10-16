describe "student_task list page" do
  before(:each) do
    # create assignment and topic
    create(:assignment, name: "Assignment1684", directory_path: "Assignment1684")
    create_list(:participant, 3)
    create(:topic, topic_name: "Topic")
    create(:deadline_type, name: "submission")
    create(:deadline_type, name: "review")
    create(:deadline_type, name: "metareview")
    create(:deadline_type, name: "drop_topic")
    create(:deadline_type, name: "signup")
    create(:deadline_type, name: "team_formation")
    create(:deadline_right)
    create(:deadline_right, name: 'Late')
    create(:deadline_right, name: 'OK')
    create(:assignment_due_date, deadline_type: DeadlineType.where(name: "submission").first, due_at: DateTime.now.in_time_zone + 1.day)
  end

  def go_to_student_task_page
    user = User.find_by(name: "student2064")
    login_as(user.name)
    stub_current_user(user, user.role.name, user.role)
    visit '/student_task/list'
    visit '/sign_up_sheet/sign_up?id=1&topic_id=1' # signup topic
    visit '/student_task/list'
  end

  it "have the right content" do
      go_to_student_task_page
      expect(page).to have_content("Assignments")
      expect(page).to have_no_content("badge")
      expect(page).to have_no_content("Review Grade")
      expect(page). to have_content("Assignment")
      expect(page). to have_content("Submission Grade")
      expect(page). to have_content("Topic")
      expect(page). to have_content("Current Stage")
      expect(page). to have_content("Stage Deadline")
      expect(page). to have_content("Publishing Rights")
      expect(page).to have_content("Assignment1684")
    end

#change part

# describe "app/views/student_task/list.html.erb" do
 it "group the course and display on different tables" do
     go_to_student_task_page
     expect(rendered).to have_tag('div', :with => { :class => "topictable"}) do
     without_tag "h1", :text => 'No Course Assigned Yet' # have course or not
     with_tag "table", :with => { :class => "table table-striped", :cellpadding => '2' } # test the Outermost layer is built
     with_tag "td",  :text => '#{student_task.course.try :name}' # test show the course name 
     end
     expect(page).to have_selector('listingRow', count: group) # the number of different tables
  end

 it "submission grade display" do
     go_to_student_task_page
     expect(rendered).to have_tag('tr', :with => { :class => "listingRow"}) do
     get :get_awarded_badges(participant) #badges shows or not 
     expect(response).to be_ok
     end
 end

 it "badges showing location fixing" do
     go_to_student_task_page
     expect(rendered).to have_tag('tr', :with => { :class => "listingRow"}) do
     without_tag "td",  :text => "-" #the topic is not empty 
     get :topic_id # topic _id shows or not 
     expect(response).to be_ok
     get :get_review_grade_info(participant) #grades shows or not 
     expect(response).to be_ok
     end
  end

 it "unnecessary white space" do
     go_to_student_task_page
     expect(rendered).to have_tag('render', :with => { :text => "publishing_rights"}) do
     with_tag "div", :class = "taskbox",float = left # taskbox is left
     with_tag "div", :class = "topictable",float = right  #topictable is right
     end

  end 

#change ends

end
