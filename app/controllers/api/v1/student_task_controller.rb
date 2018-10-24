module Api::V1
  class StudentTaskController < BasicApiController
      # helper :submitted_content
    before_action :getAssignment , only: [ :metareview_allowed, :submission_allowed, :check_reviewable_topic, :get_current_stage,
                                            :quiz_allowed]
    
    include StudentTaskHelper

    def getAssignment
      @assignment = Assignment.find(params[:assignment_id])
    end

    def action_allowed?
      ['Instructor', 'Teaching Assistant', 'Administrator', 'Super-Administrator', 'Student'].include? current_role_name
    end

    def time_ago_in_words(duedate)
    end
  
    def list
      @student_tasks = StudentTask.from_user current_user
      @student_tasks.select! {|t| t.assignment.availability_flag }
      @student_task_array = []

      @hasTopics = false
      @hasBadges = false

      
      @student_tasks.each do |student_task|
        participant = student_task.participant
        hash = {}
        student_task.instance_variables.each {|var| hash[var.to_s] = student_task.instance_variable_get(var) }
        if(student_task.course_name) 
          hash['course_name'] = student_task.course_name
        end
        topic_id = SignedUpTeam.topic_id(participant.parent_id, participant.user_id)

        if SignUpTopic.exists?(topic_id)
          hash['topic'] = SignUpTopic.find(topic_id).try :topic_name
          @hasTopics = true
        end
        if(get_awarded_badges(participant) != "")
          @hasBadges = true
        end
        hash['badges'] = get_awarded_badges(participant)
        hash['review_grade'] = get_review_grade_info(participant)
        #  puts(student_task.stage_deadline.in_time_zone(session[:user].timezonepref))
        hash['stage_deadline'] = student_task.stage_deadline.in_time_zone(@current_user.timezonepref)
        @student_task_array.push(hash)
      end
      student_task_to_json = @student_task_array.map{|s| {
                                  assignment: s["@assignment"] , 
                                  current_stage: s["@current_stage"],
                                  participant: s["@participant"], 
                                  stage_deadline: s["stage_deadline"], 
                                  topic:s["topic"],
                                  course_name: s["course_name"],
                                  badges: s["badges"],
                                  review_grade: s["review_grade"]
                                } 
                              }
      
                              # #######Tasks and Notifications##################
      @tasknotstarted = @student_tasks.select(&:not_started?)
      @tasksarray = []
      @tasknotstarted.each do |student_task|
        participant = student_task.participant
        stage = student_task.current_stage
        controller = ""
        action = ""
        if stage == "submission" || stage == 'signup'
          controller = "submitted_content"
          action = "edit"
          # check if the assignment has a sign-up sheet
          if Assignment.find(participant.assignment.id).topics?
            selected_topics = nil
            #ACS Get the topics selected by all teams
            #removed code that handles team and individual assignments differently
            # get the user's team and check if they have signed up for a topic yet
            users_team = SignedUpTeam.find_team_users(participant.assignment.id,participant.user.id)
            if users_team.size > 0
              selected_topics = SignedUpTeam.find_user_signup_topics(participant.assignment.id,users_team[0].t_id)
            end
            if selected_topics.nil? || selected_topics.length == 0
              # there is a signup sheet and user/team hasn't signed up yet, produce a link to do so
              controller = "sign_up_sheet"
              action = "list"
            end
          end
         elsif stage == "review" or stage == "metareview"
           controller = "student_review"
           action = "list"
         end
         hash = {}
         student_task.instance_variables.each {|var| hash[var.to_s] = student_task.instance_variable_get(var) }
         hash['relative_deadline'] = student_task.relative_deadline
         hash['participant'] = participant
         @tasksarray.push(hash)
        end

        tasks_to_json = @tasksarray.map{|s| {
                                  assignment: s["@assignment"] , 
                                  current_stage: s["@current_stage"], 
                                  relative_deadline: s["relative_deadline"],
                                  participant: s["participant"],
                                  participant_id: s["participant_id"]
                                  } 
                              }
      

      @taskrevisions = @student_tasks.select(&:revision?)
      @revisionsArray = []
      @taskrevisions.each do |student_task|
        participant = student_task.participant
        stage = student_task.current_stage
        topic_id = SignedUpTeam.topic_id(participant.parent_id, participant.user_id)
        duedate = participant.assignment.stage_deadline(topic_id)
        #participant_id = student_task.participant_id
        controller = ""
        action = ""
        if stage == "submission"
          controller = "submitted_content"
          action = "edit"
        elsif stage == "review" or stage == "metareview"
          controller = "student_review"
          action = "list"
        end

        hash = {}
        # student_task.instance_variables.each {|var| hash[var.to_s] = student_task.instance_variable_get(var) }
        hash['stage'] = stage
        #hash['time_to_go'] = time_ago_in_words(duedate)
        hash['controller'] = controller
        hash['action'] = action
        hash['topic_id'] = topic_id
        hash['participant'] = participant
        #hash['participant_id'] = participant_id
        hash['assignment'] = participant.assignment.name
        @revisionsArray.push(hash)

      end

      revisions_to_json = @revisionsArray.map{|s| {
                                  assignment: s["assignment"] , 
                                  stage: s["stage"], 
                                  time_to_go: s["time_to_go"],
                                  controller: s["controller"],
                                  action: s["action"],
                                  topic_id: s["topic_id"],
                                  participant: s["participant"],
                                  participant_id: s["participant_id"]
                                  } 
                              }
      ######## Students Teamed With###################
      @students_teamed_with = StudentTask.teamed_students(current_user, session[:ip]).values
      @teamCourse = StudentTask.teamed_students(current_user, session[:ip]).keys
      # @teamCourse = ["CSC 517"]
      

      render json: {status: :ok, studentsTeamedWith: @students_teamed_with, 
                    studentTasks: student_task_to_json, tasks_not_started: tasks_to_json, 
                    taskrevisions: revisions_to_json, teamCourse: @teamCourse, 
                    containsTopics: @hasTopics, containsBadges: @hasBadges}
      # render json: {status: :ok, studentsTeamedWith: @students_teamed_with, studentTasks: @student_tasks}
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
  
    def get_review_grade_information

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

    def quiz_allowed
      quiz_allowed = @assignment.quiz_allowed(params[:topic_id])
      render json: {status: :ok, quiz_allowed: quiz_allowed}
    end

    def unsubmitted_self_review
      unsubmitted_self_review = unsubmitted_self_review?(params[:participant_id])
      render json: {status: :ok, unsubmitted_self_review: unsubmitted_self_review}
    end
  end
end