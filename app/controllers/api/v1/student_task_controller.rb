module Api::V1
  class StudentTaskController < BasicApiController
      # helper :submitted_content
    before_action :getAssignment , only: [ :metareview_allowed, :submission_allowed, :check_reviewable_topic, :get_current_stage]
    
    include StudentTaskHelper

    def getAssignment
      @assignment = Assignment.find(params[:assignment_id])
    end

    def action_allowed?
      ['Instructor', 'Teaching Assistant', 'Administrator', 'Super-Administrator', 'Student'].include? current_role_name
    end
  
    def list
      @student_tasks = StudentTask.from_user current_user
      @student_tasks.select! {|t| t.assignment.availability_flag }
      # @student_task_array = []
      
      # @student_tasks.each do |student_task|
      #   hash = {}
      #   student_task.instance_variables.each {|var| hash[var.to_s] = student_task.instance_variable_get(var) }
      #   if(student_task.course_name) 
      #     hash['course_name'] = student_task.course_name
      #     puts hash
      #   end
      #   @student_task_array.push(hash)
      # end
      # student_task_to_json = @student_task_array.map{|s| {
      #                             assignment: s["@assignment"] , 
      #                             current_stage: s["@current_stage"],
      #                             participant: s["@participant"] , 
      #                             stage_deadline:s["@stage_deadline"], 
      #                             topic:s["@topic"],
      #                             course_name: s["course_name"]} 
      #                         }
      
                              # #######Tasks and Notifications##################
      @tasknotstarted = @student_tasks.select(&:not_started?)
      @taskrevisions = @student_tasks.select(&:revision?)
  
      ######## Students Teamed With###################
      @students_teamed_with = StudentTask.teamed_students(current_user, session[:ip])

      # render json: {status: :ok, studentsTeamedWith: @students_teamed_with, studentTasks: student_task_to_json}
      render json: {status: :ok, studentsTeamedWith: @students_teamed_with, studentTasks: @student_tasks}
    end


    def view
      puts 'in student task controller view'
      StudentTask.from_participant_id params[:id]
      @participant = AssignmentParticipant.find(params[:id])
      @can_submit = @participant.can_submit
      @can_review = @participant.can_review
      @can_take_quiz = @participant.can_take_quiz
      @authorization = Participant.get_authorization(@can_submit, @can_review, @can_take_quiz)
      @team = @participant.team
      flag = false
      if(!current_user_id?(@participant.user_id))
        # flag = true          adjusting for getting data it should be flag = true
        flag = false
      end
      if(!flag)
        @assignment = @participant.assignment
        @can_provide_suggestions = @assignment.allow_suggestions
        @topic_id = SignedUpTeam.topic_id(@assignment.id, @participant.user_id)
        @topics = SignUpTopic.where(assignment_id: @assignment.id)
        # Timeline feature
        @timeline_list = StudentTask.get_timeline_data(@assignment, @participant, @team)
      
        render json: {  status: :ok,  
                      participant: @participant, 
                      can_submit: @can_submit,
                      can_review: @can_review,
                      can_take_quiz: @can_take_quiz,
                      authorization: @authorization,
                      denied: flag,
                      team: @team,
                      assignment: @assignment,
                      can_provide_suggestions: @can_provide_suggestions,
                      topic_id: @topic_id,
                      topics: @topics,
                      timeline_list: @timeline_list
                    }
      else 
        render json: {status: :ok , denied: flag}
      end
    end
  
    def metareview_allowed
      metareview_allowed = @assignment.metareview_allowed(params[:topic_id])
      render json: { status: :ok, metareview_allowed: metareview_allowed}
    end
  
    def submission_allowed  
      sub_allowed = @assignment.submission_allowed( params[:topic_id])
      render json: { status: :ok , sub_allowed: sub_allowed }
    end
  
    def check_reviewable_topic
      check_reviewable_topics = check_reviewable_topics @assignment
      render json: {status: :ok , check_reviewable_topics: check_reviewable_topics }
    end

    def get_current_stage
      get_current_stage = @assignment.get_current_stage(params[:topic_id])
      render json: { status: :ok, get_current_stage: get_current_stage}
    end
  end
end