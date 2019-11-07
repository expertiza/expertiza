class StudentTaskController < ApplicationController
  helper :submitted_content

  def action_allowed?
    ['Instructor', 'Teaching Assistant', 'Administrator', 'Super-Administrator', 'Student'].include? current_role_name
  end

  def impersonating_as_admin?
    original_user = session[:original_user]
    admin_role_ids = Role.where(name:['Administrator','Super-Administrator']).pluck(:id)
    admin_role_ids.include? original_user.role_id
  end

  def impersonating_as_ta?
    original_user = session[:original_user]
    ta_role = Role.where(name:['Teaching Assistant']).pluck(:id)
    ta_role.include? original_user.role_id
  end

  def list
    redirect_to(controller: 'eula', action: 'display') if current_user.is_new_user
    session[:user] = User.find_by(id: current_user.id)
    @student_tasks = StudentTask.from_user current_user
    if session[:impersonate] && !impersonating_as_admin?

      if impersonating_as_ta?
        ta_course_ids = TaMapping.where(:ta_id => session[:original_user].id).pluck(:course_id)
        @student_tasks = @student_tasks.select {|t| ta_course_ids.include?t.assignment.course_id }
      else
        @student_tasks = @student_tasks.select {|t| session[:original_user].id == t.assignment.course.instructor_id }
      end
    end
    @student_tasks.select! {|t| t.assignment.availability_flag }

    # #######Tasks and Notifications##################
    @tasknotstarted = @student_tasks.select(&:not_started?)
    @taskrevisions = @student_tasks.select(&:revision?)

    ######## Students Teamed With###################
    @students_teamed_with = StudentTask.teamed_students(current_user, session[:ip])
  end

  def view
    StudentTask.from_participant_id params[:id]
    @participant = AssignmentParticipant.find(params[:id])
    @can_submit = @participant.can_submit
    @can_review = @participant.can_review
    @can_take_quiz = @participant.can_take_quiz
    @authorization = Participant.get_authorization(@can_submit, @can_review, @can_take_quiz)
    @team = @participant.team
    denied unless current_user_id?(@participant.user_id)
    @assignment = @participant.assignment
    @can_provide_suggestions = @assignment.allow_suggestions
    @topic_id = SignedUpTeam.topic_id(@assignment.id, @participant.user_id)
    @topics = SignUpTopic.where(assignment_id: @assignment.id)
    # Timeline feature
    @timeline_list = StudentTask.get_timeline_data(@assignment, @participant, @team)
    #THE FOLLOWING CODE IS ADDED FOR THE TAG COUNT FEATURE
    #http://wiki.expertiza.ncsu.edu/index.php/CSC/ECE_517_Fall_2019_-_E1953._Tagging_report_for_student
    #This code is meant to help display the total number of tags completed by this user for this
    #assignment.
    #Get all questionnaires for the assignment
    questionnaires = @assignment.questionnaires
    #vmlist holds all VmQuestionResponses for this assignment
    vmlist = []
    #Fixes a bug where students without submissions crash this page
    if !@team.nil?
      questionnaires.each do |questionnaire|
        @round = nil
        #This code does not make sense but was borrowed from GradesController.view_team which worked
        if @assignment.varying_rubrics_by_round? && questionnaire.type == "ReviewQuestionnaire"
          questionnaires = AssignmentQuestionnaire.where(assignment_id: @assignment.id, questionnaire_id: questionnaire.id)
          if questionnaires.count > 1
            @round = questionnaires[counter_for_same_rubric].used_in_round
            counter_for_same_rubric += 1
          else
            @round = questionnaires[0].used_in_round
            counter_for_same_rubric = 0
          end
        end
        #A VmQuestionResponse helps count the number of tags the user has done/should do.
        vm = VmQuestionResponse.new(questionnaire, @assignment, @round)
        vmquestions = questionnaire.questions
        vm.add_questions(vmquestions)
        vm.add_team_members(@team)
        vm.add_reviews(@participant, @team, @assignment.varying_rubrics_by_round?)
        vm.number_of_comments_greater_than_10_words
        vmlist << vm
      end
    end
    #completed_tags holds the number of tags this user has completed
    @completed_tags = 0
    #total tags holds the number of tags which it is possible to fill out for this user for this assignment
    @total_tags = 0
    vmlist.each do |vm|
      #Each row corresponds to a row of tags to complete
      vm.list_of_rows.each do |r|
        r.score_row.each do |row|
          #Checkboxes can be left empty and they will still be "completed" tags. That's why this type
          #of tag is ignored
          vm_prompts = row.vm_prompts.select {|prompt| prompt.tag_dep.tag_prompt.control_type.downcase != "checkbox"}
          #Increment by the number of tag prompts it is possible to fill out for this row
          @total_tags += vm_prompts.count
          #For each tag it is possible to do
          vm_prompts.each do |vm_prompt|
            #Grab the answer the user has given for this tag
            answer_tag = AnswerTag.where(tag_prompt_deployment_id: vm_prompt.tag_dep, user_id: @participant.user_id, answer: vm_prompt.answer).first
            #For non-checkbox answer tags, 0 indicates the user has not completed this tag
            if !answer_tag.nil? and answer_tag.value != "0"
              @completed_tags += 1
            end
          end
        end
      end
    end
  end

  def others_work
    @participant = AssignmentParticipant.find(params[:id])
    return unless current_user_id?(@participant.user_id)

    @assignment = @participant.assignment
    # Finding the current phase that we are in
    due_dates = AssignmentDueDate.where(parent_id: @assignment.id)
    @very_last_due_date = AssignmentDueDate.where(parent_id: @assignment.id).order("due_at DESC").limit(1)
    next_due_date = @very_last_due_date[0]
    for due_date in due_dates
      if due_date.due_at > Time.now
        next_due_date = due_date if due_date.due_at < next_due_date.due_at
      end
    end

    @review_phase = next_due_date.deadline_type_id
    if next_due_date.review_of_review_allowed_id == DeadlineRight::LATE or next_due_date.review_of_review_allowed_id == DeadlineRight::OK
      @can_view_metareview = true if @review_phase == DeadlineType.find_by(name: "metareview").id
    end

    @review_mappings = ResponseMap.where(reviewer_id: @participant.id)
    @review_of_review_mappings = MetareviewResponseMap.where(reviewer_id: @participant.id)
  end

  def your_work; end
end
