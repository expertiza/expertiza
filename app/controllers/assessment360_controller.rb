class Assessment360Controller < ApplicationController
  # Added the @instructor to display the instrucor name in the home page of the 360 degree assessment
  def index
    @courses = Course.find_all_by_instructor_id(session[:user].id)
    @instructor_id = session[:user].id
    @instructor = User.find_by_id(@instructor_id)
  end

  def one_course_all_assignments
    puts "inside one course all assignment"
    #@REVIEW_TYPES = ["ParticipantReviewResponseMap", "FeedbackResponseMap", "TeammateReviewResponseMap", "MetareviewResponseMap"]
    @REVIEW_TYPES = ["TeammateReviewResponseMap"]
    @course = Course.find_by_id(params[:course_id])
    @assignments = Assignment.find_all_by_course_id(@course)
    @assignments.reject! {|assignment| assignment.get_total_reviews_assigned_by_type(@REVIEW_TYPES.first) == 0 }

    @assignment_pie_charts = Hash.new
    @assignment_bar_charts = Hash.new
    @assignment_distribution  = Hash.new

    @assignments.each do |assignment|
      # Pie Chart Data .....................................
      reviewed = assignment.get_percentage_reviews_completed()
      pending = 100 - reviewed
      reviewed_msg = reviewed.to_s + "% reviewed"
      pending_msg = pending.to_s + "% pending"

      GoogleChart::PieChart.new('160x100'," ",false) do |pc|
        pc.data_encoding = :extended
        pc.data reviewed_msg, reviewed, '228b22' # want to write '20' responed
        pc.data pending_msg, pending, 'ff0000' # rest of the class

        # Pie Chart with labels
        pc.show_labels = false
        pc.show_legend = true
        @assignment_pie_charts[assignment] = (pc.to_url)
      end

      # bar chart data ................................
      bar_1_data = Array.new
      dates = Array.new
      date = assignment.created_at.to_datetime.to_date

      while ((date <=> Date.today) <= 0)
        if assignment.get_total_reviews_completed_by_type_and_date(@REVIEW_TYPES.first, date) != 0 then
          bar_1_data.push(assignment.get_total_reviews_completed_by_type_and_date(@REVIEW_TYPES.first, date))
          dates.push(date.month.to_s + "-" + date.day.to_s)
        end

        date = (date.to_datetime.advance(:days => 1)).to_date
      end

      color_1 = 'c53711'
      min=0
      max= assignment.get_total_reviews_assigned

      GoogleChart::BarChart.new("600x80", " ", :vertical, false) do |bc|
        bc.data "Review", bar_1_data, color_1
        bc.axis :y, :positions => [min, max], :range => [min,max]
        bc.axis :x, :labels => dates
        bc.show_legend = false
        bc.stacked = false
        bc.data_encoding = :extended
        bc.params.merge!({:chl => "Nov"})
        @assignment_bar_charts[assignment] = (bc.to_url)
      end
      
      # Histogram score distribution .......................
      bar_2_data = assignment.get_score_distribution
      color_2 = '4D89F9'
      min = 0
      max = 100

      p '======================='
      p bar_2_data
      GoogleChart::BarChart.new("130x100", " ", :vertical, false) do |bc|
        bc.data "Review", bar_2_data, color_2
        bc.axis :y, :positions => [0, bar_2_data.max], :range => [0, bar_2_data.max]
        bc.axis :x, :positions => [min, max], :range => [min,max]
        bc.width_spacing_options :bar_width => 1, :bar_spacing => 0, :group_spacing => 0
        bc.show_legend = false
        bc.stacked = false
        bc.data_encoding = :extended
        bc.params.merge!({:chl => "Nov"})
        @assignment_distribution[assignment] = (bc.to_url)
      end
    end
  end

  def all_assignments_all_students
    @course = Course.find_by_id(params[:course_id]);
    @assignments = Assignment.find_all_by_course_id(@course)
  end

  def one_assignment_all_students
    @assignment = Assignment.find_by_id(params[:assignment_id])
    @participants = @assignment.participants
    
    @bc = Hash.new
    @participants.each do |participant|
      @questionnaires = @assignment.questionnaires
      bar_1_data = [participant.get_average_score]
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
     @course = Course.find_by_id(params[:course_id])
     @students = @course.get_participants()
     @assignments = Assignment.find_all_by_course_id(@course.id);
  end

# Find all the assignments for a given student pertaining to the course. This data is given a graphical display using bar charts. Individual teammate and metareview scores are displayed along with their aggregate
  def one_student_all_reviews

    @course = Course.find_by_id(params[:course_id])
    @students = @course.get_participants()
    @students.each { |student|
       if student.id.to_s == params[:student_id].to_s
         @current_student = student
         break
       end
    }
    @assignments = Assignment.find_all_by_course_id(@course.id);

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
       teammate_scores = assignment_participant.get_teammate_reviews()
       meta_scores = assignment_participant.get_metareviews()
       j = 1.to_i
       average = 0;
       if !teammate_scores.nil?
         teammate_scores.each do |teammate_score|
            average = average +   teammate_score.get_average_score
            bc.data assignment.name.to_s + ", Scores: " + teammate_score.get_average_score.to_s, [teammate_score.get_average_score], colors[i]
            j = j + 1
         end
         if( (j-1).to_i > 0)
            average = average.to_i / (j-1).to_i
            bc.data assignment.name.to_s + ", Average: "+ average.to_s, [average], '000000'
         end
       end
       i = i +1
     end
     puts "\nBar Chart"
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
       meta_scores = assignment_participant.get_metareviews()
       j = 1.to_i
       average = 0;
       if !meta_scores.nil?
         meta_scores.each do |meta_score|
            average = average +   meta_score.get_average_score
            bc.data assignment.name.to_s + ", Scores ".to_s +  meta_score.get_average_score.to_s, [meta_score.get_average_score], colors[i]
            j = j + 1
         end
        if( (j-1).to_i > 0)
            average = average.to_i / (j-1).to_i
            bc.data assignment.name.to_s + ", Average: "+ average.to_s, [average], '000000'
        end

       end
       i = i +1
     end
     puts "\nBar Chart"
     @mt= bc.to_url
     end
    end
  end

  def one_assignment_one_student
    @assignment = Assignment.find_by_id(params[:assignment_id])
    @participant = Participant.find_by_user_id(params[:user_id])
    @questionnaires = @assignment.questionnaires
    bar_1_data = [@participant.get_average_score]
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
