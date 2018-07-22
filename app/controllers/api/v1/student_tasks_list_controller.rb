module Api::V1
    class StudentTasksListController < BasicApiController
        helper :submitted_content
      
        def action_allowed?
          ['Instructor', 'Teaching Assistant', 'Administrator', 'Super-Administrator', 'Student'].include? current_role_name
        end
      
        def index
          redirect_to(controller: 'eula', action: 'display') if current_user.is_new_user
          session[:user] = User.find_by(id: current_user.id)
          @student_tasks = StudentTask.from_user current_user
          @student_tasks.select! {|t| t.assignment.availability_flag }
      
          # #######Tasks and Notifications##################
          @tasknotstarted = @student_tasks.select(&:not_started?)
          @taskrevisions = @student_tasks.select(&:revision?)
      
          ######## Students Teamed With###################
          @students_teamed_with = StudentTask.teamed_students(current_user, session[:ip])
         render json: {status: :ok, studentsTeamedWith: @students_teamed_with, studentTasks: @student_tasks}
             
      end
      
      end
    end