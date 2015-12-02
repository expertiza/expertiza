require File.dirname(__FILE__) + '/../test_helper'

class SubmittedContentControllerTest < ActionController::TestCase
  fixtures :courses, :teams, :users, :teams_users, :participants, :assignments, :nodes, :roles, :wiki_types, :deadline_types

  def setup
    @controller = SubmittedContentController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end


  test "submit Hyperlink for student1" do
    @request.session[:user] = User.find(users(:student1).id)
    post :submit_hyperlink , 'id' => 1, 'submission' => 'http://www.google.com'
    participant = AssignmentParticipant.find(participants(:participant1).id)
    list_of_hyperLinks = participant.hyperlinks_array
    assert_equal 1,list_of_hyperLinks.count
  end

  test "submit Hyperlink for student1 and student2" do
    @request.session[:user] = User.find(users(:student1).id)
    post :submit_hyperlink , 'id' => 1, 'submission' => 'http://www.yahoo.com'

    @request.session[:user] = User.find(users(:student2).id)
    post :submit_hyperlink , 'id' => 1, 'submission' => 'http://www.ncsu.edu'

    participant = AssignmentParticipant.find(participants(:participant1).id)
    list_of_hyperLinks = participant.hyperlinks_array
    assert_equal 2,list_of_hyperLinks.count
  end

  test "submit same hyperlink twice" do
    @request.session[:user] = User.find(users(:student1).id)
    post :submit_hyperlink , 'id' => 1, 'submission' => 'http://www.yahoo.com'

    @request.session[:user] = User.find(users(:student2).id)
    post :submit_hyperlink , 'id' => 1, 'submission' => 'http://www.yahoo.com'

    assert_equal "You or your teammate(s) have already submitted the same hyperlink.", flash[:error]

    participant = AssignmentParticipant.find(participants(:participant1).id)
    list_of_hyperLinks = participant.hyperlinks_array
    assert_equal 1,list_of_hyperLinks.count
  end

  test "remove hyperlink" do
    @request.session[:user] = User.find(users(:student1).id)
    post :submit_hyperlink , 'id' => 1, 'submission' => 'http://www.yahoo.com'
    post :submit_hyperlink , 'id' => 1, 'submission' => 'http://www.google.com'
    post :submit_hyperlink , 'id' => 1, 'submission' => 'http://www.ncsu.edu'

    participant = AssignmentParticipant.find(participants(:participant1).id)
    list_of_hyperLinks = participant.hyperlinks_array
    assert_equal 3,list_of_hyperLinks.count

    post :remove_hyperlink, :hyperlinks => { :participant_id => participants(:participant1).id} , :chk_links => '1'
    list_of_hyperLinks = participant.hyperlinks_array
    assert_equal 2,list_of_hyperLinks.count
  end

  # test "student submits a hyperlink, instructor can view the hyperlink" do
  #   @request.session[:user] = User.find(users(:student1).id)
  #   post :submit_hyperlink , 'id' => 1, 'submission' => 'http://www.yahoo.com'
  #
  #   @request.session[:user] = User.find(users(:instructor1).id)
  #   post :
  # end

  def test_directoryNum_singleParticipant_submitFile

    @request.session[:user] = User.find(users(:student1).id)
    participant1 = AssignmentParticipant.find(participants(:participant1).id)

    # Participant 1 submits a file
    post :submit_file, :id=>users(:student1).id,:uploaded_file=>ActionDispatch::Http::UploadedFile.new(tempfile: File.new("/home/expertiza_developer/expertiza/README.md"), filename: File.basename(File.new("/home/expertiza_developer/expertiza/README.md")))

    # Check the number of files as seen by Participant 1
    files= participant1.files(participant1.team.path.to_s)
    assert_equal(files.size, 1)

    # Remove all files uploaded before coming out of the test case
    FileUtils.rm_r(participant1.team.path.to_s)
  end


  def test_directoryNum_singleParticipant_deleteFile

    @request.session[:user] = User.find(users(:student1).id)
    participant1 = AssignmentParticipant.find(participants(:participant1).id)

    # Participant 1 submits a file
    post :submit_file, :id=>users(:student1).id,:uploaded_file=>ActionDispatch::Http::UploadedFile.new(tempfile: File.new("/home/expertiza_developer/expertiza/README.md"), filename: File.basename(File.new("/home/expertiza_developer/expertiza/README.md")))

    # Check the number of files as seen by Participant 1
    files= participant1.files(participant1.team.path.to_s)
    assert_equal(files.size, 1)

    # Participant 1 deletes the file
    post :folder_action, :id=>users(:student1).id, :chk_files=>'1', :faction=>{:delete=>""}, :directories=>{"1"=>participant1.team.path.to_s}, :filenames=>{"1"=>"README.md"}

    # Check the number of files as seen by Participant 1
    files= participant1.files(participant1.team.path.to_s)
    assert_equal(files.size, 0)

    # Remove all files uploaded before coming out of the test case
    FileUtils.rm_r(participant1.team.path.to_s)
  end


  def test_directoryNum_multipleParticipants_submitFile

    @request.session[:user] = User.find(users(:student1).id)
    participant1 = AssignmentParticipant.find(participants(:participant1).id)
    participant2 = AssignmentParticipant.find(participants(:participant2).id)

    # Participant 1 submits File 1
    post :submit_file, :id=>participants(:participant1).id,:uploaded_file=>ActionDispatch::Http::UploadedFile.new(tempfile: File.new("/home/expertiza_developer/expertiza/README.md"), filename: File.basename(File.new("/home/expertiza_developer/expertiza/README.md")))

    # Check the number of files as seen by Participant 1
    files= participant1.files(participant1.team.path.to_s)
    assert_equal(files.size, 1)

    # Check the number of files as seen by Participant 2
    files= participant2.files(participant2.team.path.to_s)
    assert_equal(files.size, 1)

    # Participant 1 submits File 2
    post :submit_file, :id=>participants(:participant1).id,:uploaded_file=>ActionDispatch::Http::UploadedFile.new(tempfile: File.new("/home/expertiza_developer/expertiza/prototype.js"), filename: File.basename(File.new("/home/expertiza_developer/expertiza/prototype.js")))

    # Check the number of files as seen by Participant 1
    files= participant1.files(participant1.team.path.to_s)
    assert_equal(files.size, 2)

    # Check the number of files as seen by Participant 2
    files= participant2.files(participant2.team.path.to_s)
    assert_equal(files.size, 2)

    # Remove all files uploaded before coming out of the test case
    FileUtils.rm_r(participant2.team.path.to_s)
  end


  def test_directoryNum_multipleParticipants_deleteFile

    @request.session[:user] = User.find(users(:student1).id)
    participant1 = AssignmentParticipant.find(participants(:participant1).id)
    participant2 = AssignmentParticipant.find(participants(:participant2).id)

    # Participant 1 submits file 1
    post :submit_file, :id=>participants(:participant1).id,:uploaded_file=>ActionDispatch::Http::UploadedFile.new(tempfile: File.new("/home/expertiza_developer/expertiza/README.md"), filename: File.basename(File.new("/home/expertiza_developer/expertiza/README.md")))

    # Participant 1 submits file 2
    post :submit_file, :id=>participants(:participant1).id,:uploaded_file=>ActionDispatch::Http::UploadedFile.new(tempfile: File.new("/home/expertiza_developer/expertiza/Gemfile"), filename: File.basename(File.new("/home/expertiza_developer/expertiza/Gemfile")))


    # Check the number of files as seen by Participant 1
    files= participant1.files(participant1.team.path.to_s)
    assert_equal(files.size, 2)

    # Check the number of files as seen by Participant 2
    files= participant2.files(participant2.team.path.to_s)
    assert_equal(files.size, 2)

    # Participant 1 deletes file 1
    post :folder_action, :id=>participants(:participant1).id, :chk_files=>'1', :faction=>{:delete=>""}, :directories=>{"1"=>participant1.team.path.to_s, "2"=>participant1.team.path.to_s}, :filenames=>{"1"=>"README.md","2"=>"Gemfile"}

    # Check the number of files as seen by Participant 1
    files= participant1.files(participant1.team.path.to_s)
    assert_equal(files.size, 1)

    # Check the number of files as seen by Participant 2
    files= participant2.files(participant2.team.path.to_s)
    assert_equal(files.size, 1)

    # Remove all files uploaded before coming out of the test case
    FileUtils.rm_r(participant1.team.path.to_s)
  end

end
