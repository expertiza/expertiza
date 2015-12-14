# Method to create assignment before running feature test for assignment submission by student
include LogInHelper 

module SubmittedContentTestHelper
  def create_assignment
	instructor.save
    @instructor = instructor
	student.save
    @student = student
	wiki_id = WikiType.all.first.id
	
	Course.new(
		:name => 'testCourse',
	    :instructor_id => @instructor.id, 
		:directory_path => 'testCourse').save
	course_id = Course.all.first.id

    @assignment = Assignment.new(
        :name => 'Assignment1',
        :directory_path => "csc517/oss",
        :instructor_id => @instructor.id,
        :max_team_size => 1,
        :course_id => course_id,
        :wiki_type_id => wiki_id,
        :reviews_visible_to_all => 0,
        :staggered_deadline => 0,
        :allow_suggestions => 0,
        :review_assignment_strategy => "Auto-Selected",
        :require_quiz => 0,
        :is_coding_assignment => 0,
        :is_intelligent => 0,
        :availability_flag => 1,
        :show_teammate_reviews => 0,
        :use_bookmark => 0)

    @assignment.save
    due_date= DueDate.new(
        :due_at => 5.days.from_now,
        :deadline_type_id => 1,
        :assignment_id => @assignment.id,
        :submission_allowed_id => 3,
        :review_allowed_id => 1,
        :review_of_review_allowed_id => 1 ,
        :round => 1,
        :flag => 0,
        :threshold => 1,
        :teammate_review_allowed_id => 1)

    due_date.save


    # Generate a node for the created assignment
    node= Node.new(
        :parent_id => 3920,
        :node_object_id => @assignment.id,
        :type => "AssignmentNode")

    node.save

    # Add @student as a participant to the created assignment
    participant = Participant.new(
        :parent_id => @assignment.id,
        :user_id => @student.id,
        :permission_granted => 0,
        :type => "AssignmentParticipant",
        :handle => "handle")

   @partcipant =  participant.save
  end
end
