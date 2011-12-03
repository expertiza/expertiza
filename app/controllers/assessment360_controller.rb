#SNVP:::Controller has been modified for the E317-Assessment 360 project.
class Assessment360Controller < ApplicationController

  def index
    @courses = Course.find_all_by_instructor_id(session[:user].id)
  end

  def one_assignment_statistics
    @choice = params[:choice]
    @assignment = Assignment.find(params[:assignment_id])
    @participants = @assignment.get_participants
    @types = {'Metareview' => 'MetareviewResponseMap','Feedback' => 'FeedbackResponseMap','Teammate Reviews' => 'TeammateReviewResponseMap','Participant Review' => 'ParticipantReviewResponseMap','Team Review' => 'TeamReviewResponseMap'}

  end

  def one_course_statistics
    course_id = params[:course_id]
    @course = Course.find(course_id)
    @assignments = Assignment.find_all_by_course_id(@course)

    @types = {'Metareview' => 'MetareviewResponseMap','Feedback' => 'FeedbackResponseMap','Teammate Reviews' => 'TeammateReviewResponseMap','Participant Review' => 'ParticipantReviewResponseMap','Team Review' => 'TeamReviewResponseMap'}
  end

  def show_student_list
    @choice = params[:choice]
    @course = Course.find(params[:course_id])
    @assignments = Assignment.find_all_by_course_id(@course)

    flag = params[:flag]

    @allUsers = @course.get_course_participants
  end

  def one_course_all_assignments
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


  def one_course_all_students
    @REVIEW_TYPES = ["ParticipantReviewResponseMap", "FeedbackResponseMap", "TeammateReviewResponseMap", "MetareviewResponseMap","TeamReviewResponseMap"]
    @course=Course.find_by_id(params[:course_id]);
    @course_assigned_reviews_count=0
    @unique_users=@course.get_course_participants

       @unique_users.each do |user|
          @course_assigned_reviews_count+=user.get_total_reviews_assigned
       end
    @course
    @unique_users
    @course_assigned_reviews_count
  end

  def one_student_all_assignments
   @REVIEW_TYPES = ["ParticipantReviewResponseMap", "FeedbackResponseMap", "TeammateReviewResponseMap", "MetareviewResponseMap","TeamReviewResponseMap"]
   @user=User.find(params[:user_id])
   @participants=Participant.find_all_by_user_id(params[:user_id])
    bar_1_data = @user.get_total_reviews_completed
    bar_2_data = params[:count]
    @contribution = (((bar_1_data).to_f)/((bar_2_data).to_f))*100
    puts("--contribution", @contribution.to_f)
    color_1 = 'c53711'
    color_2 = '0000ff'
    min=0
    max=100
    puts(bar_1_data)
    puts(bar_2_data)
    puts (bar_1_data).is_a? Integer
    puts (bar_2_data).is_a? Integer

    abc=GoogleChart::BarChart.new("800x100", "Bar Chart", :horizontal, false)
    abc.data " ", [100], 'ffffff'
    abc.data "Total no. of reviews completed by student", [bar_1_data], color_1
    abc.data "Total no. of reviews completed by class", [bar_2_data.to_i], color_2
    abc.axis :x, :range => [min,max]
    abc.show_legend = true
    abc.stacked = false
    abc.data_encoding = :extended
    puts abc
    @abc=abc.to_url
    #puts abc.to_url({:chm => "000000,0,0.1,0.11"})
    #abc.process_data()
    end


 def all_assignments_all_students
    @course = Course.find_by_id(params[:course_id])
    @assignments = Assignment.find_all_by_course_id(@course)
    @types = {'Metareview' => 'MetareviewResponseMap','Feedback' => 'FeedbackResponseMap','Teammate Reviews' => 'TeammateReviewResponseMap','Participant Review' => 'ParticipantReviewResponseMap','Team Review' => 'TeamReviewResponseMap'}
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

    GoogleChart::BarChart.new("300x80", " ", :horizontal, false) do |bc|
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
