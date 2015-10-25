class Assessment360Controller < ApplicationController
    # Added the @instructor to display the instrucor name in the home page of the 360 degree assessment

    def action_allowed?
        true
    end  

    def index
        @courses = Course.where(instructor_id: session[:user].id)
        @instructor_id = session[:user].id
        @instructor = User.find(@instructor_id)
    end

    def reviews_progress(assignments, graph_type)

        @assignment_charts = Hash.new

        assignments.each do |assignment|
            @assignment_charts[assignment] = assignment.review_progress_pie_chart if graph_type.eql? "PieChart"
            @assignment_charts[assignment] = assignment.review_progress_bar_chart if graph_type.eql? "BarChart"
            @assignment_charts[assignment] = assignment.review_grade_distribution_histogram if graph_type.eql? "Histogram"
        end
        @assignment_charts
    end

    def one_course_all_assignments
        @REVIEW_TYPES = ["ReviewResponseMap", "FeedbackResponseMap", "TeammateReviewResponseMap", "MetareviewResponseMap"]
        # @REVIEW_TYPES = ["TeammateReviewResponseMap"]
        @GRAPH_TYPES = ["PieChart", "BarChart", "Histogram"]
        @course = Course.find(params[:course_id])
        @assignments = Assignment.where(course_id: @course)
        @listAssignments = []
        if !@assignments.nil?
            #Why Reject?
            (0..@REVIEW_TYPES.length-1).each do |i|
              @listAssignments[i] = @assignments.reject {|assignment| assignment.get_total_reviews_assigned_by_type(@REVIEW_TYPES[i]) != 0 }

              @assignment_pie_charts = reviews_progress(@listAssignments[i], @GRAPH_TYPES.first)
              @assignment_bar_charts = reviews_progress(@listAssignments[i], @GRAPH_TYPES.second)
              @assignment_distribution  = reviews_progress(@listAssignments[i], @GRAPH_TYPES.last)
            end
        end
    end

    def all_assignments_all_students
        @course = Course.find(params[:course_id]);
        @assignments = Assignment.where(course_id: @course)
    end

    def one_assignment_all_students
        @assignment = Assignment.find(params[:assignment_id])
        @participants = @assignment.participants

        @bc = Hash.new
        @participants.each do |participant|
            @questionnaires = @assignment.questionnaires
            bar_1_data = [participant.average_score*20]
            color_1 = 'c53711'
            min = 0
            max = 100

            GoogleChart::BarChart.new("300x40", " ", :horizontal, false) do |bc|
                bc.data " ", [100], 'ffffff'
                bc.data "Student", bar_1_data, color_1
                bc.axis :x, :range => [min,max]
                bc.show_legend = false
                bc.stacked = false
                bc.data_encoding = :extended
                @bc[participant.user.id] = bc.to_url
            end
        end
    end

    # Find the list of all students and assignments pertaining to the course. This data is used to compute the metareview and teammate review scores. This information is used in the view.
    def all_students_all_reviews
        
        @course = Course.find(params[:course_id])
        @assignments = Assignment.where(course_id: @course)
        @students = @course.get_participants

        @class_averge_sym = :class_average
        @meta_review_sym  = :meta_review
        @teammate_review_sym = :teammate_review

        meta_hash = Hash.new 
        meta_count_hash = Hash.new 

        teammate_hash = Hash.new 
        teammate_count_hash = Hash.new 

        @meta_review = Hash.new {|h,k| h[k] = Hash.new(&h.default_proc)}
        @teammate_review = Hash.new {|h,k| h[k] = Hash.new(&h.default_proc)}
        @student_overall_average = Hash.new {|h,k| h[k] = Hash.new(&h.default_proc)}
        @class_overall_average = Hash.new {|h,k| h[k] = Hash.new(&h.default_proc)}
        @teamed_count = Hash.new {|h,k| h[k] = Hash.new(&h.default_proc)}

        @assignments.each do |assignment|   
            teammate_hash[assignment.name.to_s] = 0 
            teammate_count_hash[assignment.name.to_s] = 0 
            meta_hash[assignment.name.to_s] = 0 
            meta_count_hash[assignment.name.to_s] = 0 
        end 

        overall_teammate_average = 0
        overall_teammate_count = 0 
        overall_meta_average = 0
        overall_meta_count = 0 

        @class_overall_average[@class_averge_sym][@meta_review_sym] = ''
        @class_overall_average[@class_averge_sym][@teammate_review_sym] = ''

     #   student = @students.where(user_id: 5404)
     #   assignment = @assignments.where(name: "New problems A")
     #   assignment_participant = assignment.participants.find_by_user_id(student.user_id) 
        @students.each do |student| 
            teammate_aggregate = 0
            meta_aggregate = 0
            teammate_count = 0
            meta_count = 0 
            cp = Student.select {|c| c.id == student.user_id}.first
            @students_teamed = StudentTask.teamed_students(cp)  
            if @students_teamed[@course.id] && @students_teamed[@course.id].size
                @teamed_count[student.fullname.to_s] = @students_teamed[@course.id].size
            else
                @teamed_count[student.fullname.to_s] = 0
            end
            @assignments.each do |assignment|
                @meta_review[student.fullname.to_s][assignment.name.to_s] = ''
                @teammate_review[student.fullname.to_s][assignment.name.to_s] = ''
                @student_overall_average[student.fullname.to_s][@meta_review_sym] = ''
                @student_overall_average[student.fullname.to_s][@teammate_review_sym] = ''

                assignment_participant = assignment.participants.find_by_user_id(student.user_id) 
                if !assignment_participant.nil? 
                    teammate_reviews = assignment_participant.teammate_reviews
                    meta_reviews = assignment_participant.metareviews
                    
                    teammate_average = 0 
                    if teammate_reviews.count > 0
                        teammate_reviews.each do |teammate_review| 
                            teammate_average = teammate_average + teammate_review.get_average_score 
                        end 
                        teammate_average = (teammate_average.to_f/teammate_reviews.count.to_f).to_f.round() 
                        @teammate_review[student.fullname.to_s][assignment.name.to_s] = teammate_average.to_s + '%'
                        teammate_count_hash[assignment.name.to_s] = teammate_count_hash[assignment.name.to_s] + 1 
                    end 

                    if teammate_average > 0
                        teammate_aggregate = teammate_aggregate + teammate_average 
                        teammate_count = teammate_count+1 
                    end 

                    meta_average = 0.to_i 
                    if meta_reviews.count > 0
                        meta_reviews.each do |meta_review| 
                            meta_average = meta_average + meta_review.get_average_score 
                        end
                        meta_average = (meta_average.to_f/meta_reviews.count.to_f).to_f.round() 
                        @meta_review[student.fullname.to_s][assignment.name.to_s] = meta_average.to_s+'%'
                        meta_count_hash[assignment.name.to_s] = meta_count_hash[assignment.name.to_s] + 1 
                    end 

                    if meta_average > 0 
                        meta_aggregate = meta_aggregate + meta_average 
                        meta_count = meta_count+1 
                    end 

                    teammate_hash[assignment.name.to_s] = teammate_hash[assignment.name.to_s] + teammate_average 
                    meta_hash[assignment.name.to_s] = meta_hash[assignment.name.to_s] + meta_average 
                end 
            end 

            if meta_count.to_i > 0 
                @student_overall_average[student.fullname.to_s][:meta_review] = (meta_aggregate/meta_count).to_f.round().to_s+'%'
                overall_meta_average =  overall_meta_average + (meta_aggregate/meta_count)
                overall_meta_count = overall_meta_count + 1
            end
            if teammate_count > 0
                @student_overall_average[student.fullname.to_s][:teammate_review] = (teammate_aggregate/teammate_count).to_f.round().to_s+'%'
                overall_teammate_average =  overall_teammate_average + (teammate_aggregate/teammate_count)
                overall_teammate_count=overall_teammate_count+1
            end
        end
        #      ><b>Class Average</b><
        @assignments.each do |assignment| 
            @meta_review[@class_average_sym][assignment.name.to_s] = ''
            @teammate_review[@class_average_sym][assignment.name.to_s] = ''
            if meta_count_hash[assignment.name.to_s] > 0 
                @meta_review[@class_average_sym][assignment.name.to_s] = (meta_hash[assignment.name.to_s]/meta_count_hash[assignment.name.to_s]).to_f.round().to_s + '%'
            end 
            if teammate_count_hash[assignment.name.to_s] > 0 
                @teammate_review[@class_average_sym][assignment.name.to_s] = (teammate_hash[assignment.name.to_s]/teammate_count_hash[assignment.name.to_s]).to_f.round().to_s + '%'
            end 
        end 
        if overall_meta_count > 0 
            @class_overall_average[@class_average_sym][@meta_review_sym] = (overall_meta_average/overall_meta_count).to_f.round().to_s + '%'
        end 
        if overall_teammate_count > 0
            @class_overall_average[@class_average_sym][@teammate_review_sym] = (overall_teammate_average/overall_teammate_count).to_f.round().to_s + '%'
        end 

    end

    # Find all the assignments for a given student pertaining to the course. This data is given a graphical display using bar charts. Individual teammate and metareview scores are displayed along with their aggregate
    def one_student_all_reviews

        @course = Course.find(params[:course_id])
        @students = @course.get_participants()
        @current_student = @students.select {|student| student.id.to_s == params[:student_id].to_s}.first
        @assignments = Assignment.where(course_id: @course.id);

        colors = Array.new
        colors << '0000ff'
        colors << '00ff00'
        colors << 'ff0000'
        colors << 'ff00ff'
        colors << '00ffff'
        colors << 'ffff00'
        colors << '0f0f0f'
        colors << 'f0f0f0'
        colors << 'f00f00'
        colors << 'f0f00f'
        colors << 'ff000f'
        min = 0
        max = 100
        GoogleChart::BarChart.new("600x350"," ",:horizontal,false) do |bc|
            bc.data " ", [100], 'ffffff'
            bc.axis :x, :range => [min,max]
            i = 0
            @assignments.each do |assignment|
                assignment_participant = assignment.participants.find_by_user_id(@current_student.user_id)
                if  !assignment_participant.nil?
                    teammate_scores = assignment_participant.teammate_reviews
                    j = 0
                    average = 0;
                    if !teammate_scores.nil?
                        teammate_scores.each do |teammate_score|
                            average = average +   teammate_score.get_average_score
                            bc.data assignment.name.to_s + ", Scores: " + teammate_score.get_average_score.to_s + '%', [teammate_score.get_average_score], colors[i]
                            j = j + 1
                        end
                        if j > 0
                            average = average / j
                            bc.data assignment.name.to_s + ", Average: "+ average.to_s + '%', [average], '000000'
                        end
                    end
                    i = i + 1
                end
                @bc= bc.to_url
            end
        end

        GoogleChart::BarChart.new("600x350"," ",:horizontal,false) do |bc|
            bc.data " ", [100], 'ffffff'
            bc.axis :x, :range => [min,max]
            i = 0
            @assignments.each do |assignment|
                assignment_participant = assignment.participants.find_by_user_id(@current_student.user_id)
                if  !assignment_participant.nil?
                    meta_scores = assignment_participant.metareviews()
                    j = 0
                    average = 0;
                    if !meta_scores.nil?
                        meta_scores.each do |meta_score|
                            average = average +   meta_score.get_average_score
                            bc.data assignment.name.to_s + ", Scores ".to_s + meta_score.get_average_score.to_s + '%', [meta_score.get_average_score], colors[i]
                            j = j + 1
                        end
                        if j > 0
                            average = average.to_i / j
                            bc.data assignment.name.to_s + ", Average: "+ average.to_s + '%', [average], '000000'
                        end

                    end
                    i = i +1
                end
                @mt= bc.to_url
            end
        end
    end

    def one_assignment_one_student
        @assignment = Assignment.find(params[:assignment_id])
        @participant = AssignmentParticipant.find_by_user_id(params[:user_id])
        @questionnaires = @assignment.questionnaires
        bar_1_data = [@participant.average_score]
        bar_2_data = [@assignment.get_average_score]
        color_1 = 'c53711'
        color_2 = '0000ff'
        min=0
        max=100

        GoogleChart::BarChart.new("500x100", " ", :horizontal, false) do |bc|
            bc.data " ", [100], 'ffffff'
            bc.data "Student", bar_1_data, color_1
            bc.data "Class Average", bar_2_data, color_2
            bc.axis :x, :range => [min,max]
            bc.show_legend = true
            bc.stacked = false
            bc.data_encoding = :extended
            @bc= bc.to_url
        end
    end

    def all_assignments_one_student

    end

end
