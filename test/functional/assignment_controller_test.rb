require File.dirname(__FILE__) + '/../test_helper'
require 'assignment_controller'

# Re-raise errors caught by the controller.
class AssignmentController; def rescue_action(e) raise e end; end

class AssignmentControllerTest < Test::Unit::TestCase
  # use dynamic fixtures to populate users table
  # for the use of testing
  fixtures :users
  fixtures :assignments
  fixtures :due_dates
  def setup
    @controller = AssignmentController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    
    @request.session[:user] = User.find( users(:suadmin_user).id )
  end
  
  # Test Case 1101
  def test_new
    
    # create a new assignment
    assignment = Assignment.new( :name                => "2_valid_test",
                                 :course_id           => 1,
                                 :directory_path      => "2_valid_test",
                                 :review_questionnaire_id    => 2,                               
                                 :review_of_review_questionnaire_id => 1,
                                 :review_weight              => 100, 
                                 :author_feedback_questionnaire_id  =>11
                                )
                               #p flash[:notice].to_s
    assert assignment.save
    
    # use object assignment as the params for 
    # the 'create' method in assignment controller
#    post :create, :assignment => { :name                => "2_valid_test",
#                                 :course_id           => 1,
#                                 :directory_path      => "2_valid_test",
#                                 :review_questionnaire_id    => 2,                               
#                                 :review_of_review_questionnaire_id => 1,
#                                 :review_weight              => 100                                 
#                                 }
   #               :submit_deadline => "2007-12-03 21:27:09",
   #               :for_due_date => { "1", {:late_policy_id => 1} }
  end
  
    # Test Case 1102
  # edit an assignment, change should be 
  # reflected in DB
  def test_legal_edit_assignment
  
    @assignment = Assignment.find(1)
    number_of_assignment = Assignment.count
    post :update, :id => 1, :assignment=> { :name => 'updatedTestAssign1',
                                            :directory_path => "admin/test1",
                                            :review_questionnaire_id => 1,
                                            :review_of_review_questionnaire_id => 1,
                                            :review_weight              => 100 
                                          },
:due_date => {  "1" , { :resubmission_allowed_id =>1 ,   
                       :submission_allowed_id =>3,      
                       :review_of_review_allowed_id =>1,
                       :review_allowed_id =>1,          
                       :due_at =>"2007-07-10 15:00:00", 
                       :rereview_allowed_id =>1         
                     }                                  
            }                                           
         
                                                   
                                                      
                                             
    assert_equal flash[:notice], 'Assignment was successfully updated.'
    
    assert_response :redirect
    #assert_redirected_to :action => 'show', :id => @assignment
    assert_equal Assignment.count, number_of_assignment
    assert Assignment.find(:all, :conditions => "name = 'updatedTestAssign1'")
    #assert !Course.find(:all, :conditions => "title = 'E-Commerce'");  
    
  end
  
  # Test Case 1103
  # illegally edit an assignment, name the existing
  # assignment with an invalid name or another existing
  # assignment name, should not be allowed to changed DB data
  def test_illegal_edit_assignment
 
    @assignment = Assignment.find(1)
    number_of_assignment = Assignment.count
   # It will raise an error while execute render method in controller
   # Because the goldberg variables didn't been initialized  in the test framework
   assert_raise (ActionView::TemplateError){
    post :update, :id => 1, :assignment=> { :name => '',
                                            :directory_path => "admin/test1",
                                            :review_questionnaire_id => 1,
                                            :review_of_review_questionnaire_id => 1,
                                            :review_weight              => 100 
                                          },
:due_date => {  "1" , { :resubmission_allowed_id =>1 ,   
                       :submission_allowed_id =>3,      
                       :review_of_review_allowed_id =>1,
                       :review_allowed_id =>1,          
                       :due_at =>"2007-07-10 15:00:00", 
                       :rereview_allowed_id =>1         
                     }                                  
            }                                           
    }
    assert_template 'assignment/edit'
    assert_equal "TestAssign1", Assignment.find(1).name
  end
  
    # 1201 Delete a assignment
  def test_delete_assignment
    
    number_of_assignment = Assignment.count
    number_of_duedate = DueDate.count
    post :delete, :id => 1
    assert_redirected_to :action => 'list'
    assert_equal number_of_assignment-1, Assignment.count
    assert_raise(ActiveRecord::RecordNotFound){ Assignment.find(1) }
    
    assert number_of_duedate > DueDate.count
#assert  !DueDate.find(:all, :conditions=> "assignment_id =1")
#assert_raise(ActiveRecord::RecordNotFound)     {   ReviewFeedback.find(:all, :conditions=> "assignment_id =1")         }
#assert_raise(ActiveRecord::RecordNotFound)     {   Participant.find(:all, :conditions=> "assignment_id =1")            }
#assert_raise(ActiveRecord::RecordNotFound)     {   ReviewMapping.find(:all, :conditions=> "assignment_id =1")          }
#assert_raise(ActiveRecord::RecordNotFound)     {   ReviewOfReviewMapping.find(:all, :conditions=> "assignment_id =1")  }
#assert_raise(ActiveRecord::RecordNotFound)     {   ReviewFeedback.find(:all, :conditions=> "assignment_id =1")         }

  end
  
  
end
