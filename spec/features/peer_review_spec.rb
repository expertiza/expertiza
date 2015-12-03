require_relative '../rails_helper'

describe "the signin process", :type => :feature do
  before :each do
    def instructor
      User.where(name: 'instructor').first || User.new({
                                                           name: "instructor",
                                                           password: "password",
                                                           password_confirmation: "password",
                                                           role_id: 2,
                                                           fullname: "Dole, Bob",
                                                           email: "bdole@dev.null",
                                                           parent_id: 2,
                                                           private_by_default: false,
                                                           mru_directory_path: nil,
                                                           email_on_review: true,
                                                           email_on_submission: true,
                                                           email_on_review_of_review: true,
                                                           is_new_user: false,
                                                           master_permission_granted: 0,
                                                           handle: "",
                                                           leaderboard_privacy: false,
                                                           digital_certificate: nil,
                                                           public_key: nil,
                                                           copy_of_emails: false,
                                                       })
    end

    def student
      User.where(name: 'student').first || User.new({
                                                        "name" => "student",
                                                        "crypted_password" => "bd08fb03e2e3115964b1b39ea40625292a776a86",
                                                        "role_id" => 1,
                                                        "password_salt" => "tQ6OGFiyL9dIlwxeSJf",
                                                        "fullname" => "Student, Perfect",
                                                        "email" => "pstudent@dev.null",
                                                        "parent_id" => 1,
                                                        "private_by_default" => false,
                                                        "mru_directory_path" => nil,
                                                        "email_on_review" => true,
                                                        "email_on_submission" => true,
                                                        "email_on_review_of_review" => true,
                                                        "is_new_user" => false,
                                                        "master_permission_granted" => 0,
                                                        "handle" => "",
                                                        "leaderboard_privacy" => false,
                                                        "digital_certificate" => nil,
                                                        "timezonepref" => "Eastern Time (US & Canada)",
                                                        "copy_of_emails" => false,
                                                    })
    end

    instructor.save
    @testuser1=User.find_by_name("instructor")
    @testuser1.save
    student.save
    @user=User.find_by_name("student")
    @user.save

    @quiz=Questionnaire.new({:name => "test", :instructor_id => @testuser1.id, :max_question_score => "5", :min_question_score => "0"})
    @quiz.save

    @course=Course.new({:name => "testcourse"})
    @assignment=Assignment.new({:name => "TestAssignment", :course_id => @course.id})

    @participant1=Participant.new({:user_id => @testuser1.id, :parent_id => @assignment.id})
    @participant1.save

    @q=Question.new({:questionnaire_id => @quiz.id, :seq => "2", :txt => "hello", :type => "dropdown", :break_before => true})
    @q.save
    @answer=Answer.new({:question_id => @q.id})
    @answer.save

    @responsemap=ResponseMap.new({:reviewer_id => @user.id})
    @responsemap.save
    @response=Response.new()
    @response.save
  end

  it "signs me in" do
    visit '/'
    within("#session") do
      fill_in 'login[name]', :with => 'instructor6'
      fill_in 'login[password]', :with => 'password'
    end
    click_button 'commit'
    expect(page).to have_content 'Success'
  end

end