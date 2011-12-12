
class Assessment360Controller < ApplicationController
  def index
    @courses = Course.find_all_by_instructor_id(session[:user].id)
  end

  def one_assignment_statistics
    @choice = params[:choice]
    @assignment = Assignment.find(params[:assignment_id])
    @allParticipants = @assignment.get_participants

    @participants = Array.new
    @types = {'Participantreview' => 'ParticipantReviewResponseMap', 'Feedback' => 'FeedbackResponseMap','Teammatereview' => 'TeammateReviewResponseMap', 'Metareview' => 'MetareviewResponseMap', 'Teamreview' => 'TeamReviewResponseMap'}
    @flag = params[:flag]

    if(@flag != 'all')
      @allParticipants.each do |participant|
        if(@flag == 'submittedAll')
          if(@assignment.user_review_assignment(participant.id, 'Metareview') == "true" &&
              @assignment.user_review_assignment(participant.id, 'Feedback') == "true" &&
              @assignment.user_review_assignment(participant.id, 'Teammatereview') == "true" &&
              @assignment.user_review_assignment(participant.id, 'Participantreview') == "true" &&
              @assignment.user_review_assignment(participant.id, 'Teamreview') == "true")
             @participants << participant
          end
        elsif(@flag == 'submittedNone')
           if((@assignment.user_review_assignment(participant.id, 'Metareview') == "false") &&
              (@assignment.user_review_assignment(participant.id, 'Feedback') == "false") &&
              (@assignment.user_review_assignment(participant.id, 'Teammatereview') == "false") &&
              (@assignment.user_review_assignment(participant.id, 'Participantreview') == "false") &&
              (@assignment.user_review_assignment(participant.id, 'Teamreview') == "false"))
             @participants << participant
           end
        else
          if(@assignment.user_review_assignment(participant.id, @flag) == 'true')
            @participants << participant
          end
        end
      end
    else
      @participants = @allParticipants
    end

  end

  def one_course_statistics
    course_id = params[:course_id]
    @course = Course.find(course_id)
    @assignments = Assignment.find_all_by_course_id(@course)

    @types = {'Participantreview' => 'ParticipantReviewResponseMap', 'Feedback' => 'FeedbackResponseMap','Teammatereview' => 'TeammateReviewResponseMap', 'Metareview' => 'MetareviewResponseMap', 'Teamreview' => 'TeamReviewResponseMap'}
  end

  def show_student_list
    @choice = params[:choice]
    @course = Course.find(params[:course_id])
    @assignments = Assignment.find_all_by_course_id(@course)

    flag = params[:flag]
    @allUsers = @course.get_course_participants
    @users = Array.new

    if(flag == "all")
      @users = @allUsers
    elsif(flag == "participated")
      @allUsers.each do |user|
        reviewFlag = false
        @assignments.each do |assignment|
          if(assignment.user_review_assignment(user.id, @choice) == "true")
            reviewFlag = true
          end
        end
        if(reviewFlag == true)
          @users << user
        end
      end
    elsif(flag == "notParticipated")
      @allUsers.each do |user|
        reviewFlag = false
        @assignments.each do |assignment|
          if(assignment.user_review_assignment(user.id, @choice) == "false")
            reviewFlag = true
          end
        end
        if(reviewFlag == true)
          @users << user
        end
      end
    end
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
      # p '======================='
      #p bar_2_data
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
    @REVIEW_TYPES = ["MetareviewResponseMap", "ParticipantReviewResponseMap", "TeamReviewResponseMap", "TeammateReviewResponseMap", "FeedbackResponseMap"]
    @course=Course.find_by_id(params[:course_id])
    @unique_users=@course.get_course_participants
    #@unique_users=@course.users
    #@participants=Participant.find_all_by_user_id(params[:user_id])
    @course_assigned_reviews_count=0

       @unique_users.each do |user|
          #p "fullname : #{user.fullname}"
          @course_assigned_reviews_count += user.get_total_reviews_assigned(params[:course_id])
          #p "fullname : #{user.fullname}"
       end
    @course
    @unique_users
    @course_assigned_reviews_count
  end

  def one_student_all_assignments
   @REVIEW_TYPES = ["ParticipantReviewResponseMap", "FeedbackResponseMap", "TeammateReviewResponseMap", "MetareviewResponseMap","TeamReviewResponseMap"]
   @user=User.find(params[:user_id])
   @participants=Participant.find_all_by_user_id(params[:user_id])
   @finalParticipants = Array.new

   @course = Course.find_by_id(params[:course_id])
   @assignments = Assignment.find_all_by_course_id(@course)

   @participants.each do |participant|
     @assignments.each do |assignment|
        if((participant.parent_id == assignment.id) && (participant.type == 'AssignmentParticipant'))
           if(!@finalParticipants.include?(participant))
              #puts "participant id : " + participant.id.to_s
              @finalParticipants << participant
           end
        end
     end
   end

   @unique_users=@course.get_course_participants
   #@unique_users=@course.users

   #puts("unique users", @unique_users.count)

    @bar_1_data = @user.get_total_reviews_completed(@course.id)
    @bar_2_data = params[:count]
    @bar_3_data = (@bar_2_data.to_f)/(@unique_users.count)
    @contribution = (((@bar_1_data).to_f)/((@bar_2_data).to_f))*100
    @contribution_2 = (((@bar_1_data).to_f)/((@bar_3_data).to_f))*100
    #puts("--contribution", @contribution.to_f)
    color_1 = 'c53711'
    color_2 = '0000ff'
    color_3 = '0000ff'
    min=0
    max=100
    #puts(@bar_1_data)
    #puts(@bar_2_data)
    #puts(@bar_3_data)
    #puts (@bar_1_data).is_a? Integer
    #puts (@bar_2_data).is_a? Integer
    #puts (@bar_3_data).is_a? Integer

    abc=GoogleChart::BarChart.new("800x100", "Bar Chart", :horizontal, false)
    abc.data " ", [100], 'ffffff'
    abc.data "Total no. of reviews completed by student", [@bar_1_data], color_1
    abc.data "Total no. of reviews completed by class", [@bar_2_data.to_i], color_2
    abc.axis :x, :range => [min,max]
    abc.show_legend = true
    abc.stacked = false
    abc.data_encoding = :extended
    #puts abc
    @abc=abc.to_url
    #puts abc.to_url({:chm => "000000,0,0.1,0.11"})
    #abc.process_data()

    bc=GoogleChart::BarChart.new("800x100", "Bar Chart", :horizontal, false)
    bc.data " ", [100], 'ffffff'
    bc.data "Total no. of reviews completed by student", [@bar_1_data], color_1
    bc.data "Average no. of reviews completed by class", [@bar_3_data.to_f], color_2
    bc.axis :x, :range => [min,max]
    bc.show_legend = true
    bc.stacked = false
    bc.data_encoding = :extended
    puts bc
    @bc=bc.to_url
    end


 def all_assignments_all_students
    @course = Course.find_by_id(params[:course_id])
    @assignments = Assignment.find_all_by_course_id(@course)
    @types = {'Participantreview' => 'ParticipantReviewResponseMap', 'Feedback' => 'FeedbackResponseMap','Teammatereview' => 'TeammateReviewResponseMap', 'Metareview' => 'MetareviewResponseMap', 'Teamreview' => 'TeamReviewResponseMap'}
  end

  def one_assignment_all_students
    @assignment = Assignment.find_by_id(params[:assignment_id])
    @participants = @assignment.participants
    @final_participants = Array.new

    @flag = params[:flag]

    if(@flag == "all")
      @final_participants = @participants
    elsif(@flag == "onlyNotSubmitted")
      @participants.each do |participant|
        if(participant.responses.nil?)
          @final_participants = @participants
        end
      end
    elsif(@flag == "onlySubmitted")
      @participants.each do |participant|
        if(!participant.responses.nil?)
          @final_participants = @participants
        end
      end
    end

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
