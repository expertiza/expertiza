class Assessment360Controller < ApplicationController

	def index

		@courses = Course.find_all_by_instructor_id(session[:user].id)

	end

	def OneCourseAllAssignments

		@REVIEW_TYPES = ["ParticipantReviewResponseMap", "FeedbackResponseMap", "TeammateReviewResponseMap", "MetareviewResponseMap"];

		@course = Course.find_by_id(params[:course_id])

		@assignments = Assignment.find_all_by_course_id(@course)

		@assignment_pie_charts = Hash.new

		@assignment_bar_charts = Hash.new

		@assignments.each do |assignment|

			review_pie_charts = Hash.new

			review_bar_charts = Hash.new

			@REVIEW_TYPES.each do |type|

				# Pie Chart Data .....................................

				responded = assignment.getTotalReviewsCompletedByType(type)

				not_resp= assignment.getTotalReviewsAssignedByType(type) - assignment.getTotalReviewsCompletedByType(type)

				resp_str=responded.to_s

				not_resp_str=not_resp.to_s

				GoogleChart::PieChart.new('160x100'," ",false) do |pc|

					pc.data_encoding = :extended

					pc.data  resp_str+" Responded" , responded  ,'0000ff' # want to write '20' responed

					pc.data not_resp_str+" Left",not_resp  , 'ff0000' # rest of the class

					# Pie Chart with labels

					pc.show_labels = false

					pc.show_legend=true

					review_pie_charts[type] = (pc.to_url)

				end

				# bar chart data ................................

				bar_1_data = Array.new

				dates = Array.new

				date = assignment.created_at.to_datetime.to_date

				while ((date <=> Date.today) <= 0)

					if assignment.getTotalReviewsCompletedByTypeByDate(type, date) != 0 then

						bar_1_data.push(assignment.getTotalReviewsCompletedByTypeByDate(type, date))

						dates.push(date.month.to_s + "-" + date.day.to_s)

					end

					date = (date.to_datetime.advance(:days => 1)).to_date

				end

				color_1 = 'c53711'

				min=0

				max= assignment.getTotalReviewsAssigned

				GoogleChart::BarChart.new("300x80", " ", :vertical, false) do |bc|

					bc.data "Review", bar_1_data, color_1

					bc.axis :y, :positions => [min, max], :range => [min,max]

					bc.axis :x, :labels => dates

					bc.show_legend = true

					bc.stacked = false

					bc.data_encoding = :extended

					bc.params.merge!({:chl => "Nov"})

					#   bc.shape_marker :circle, :color => '00ff00', :data_set_index => 1, :data_point_index => -1, :pixel_size => 10

					review_bar_charts[type] = (bc.to_url)

				end

			end

			@assignment_pie_charts[assignment] = review_pie_charts

			@assignment_bar_charts[assignment] = review_bar_charts

		end

	end

	def AllAssignmentsAllStudents

		@course = Course.find_by_id(params[:course_id]);

		@assignments = Assignment.find_all_by_course_id(@course)

	end

	def OneAssignmentAllStudents

		@assignment = Assignment.find_by_id(params[:assignment_id])

		@participants = @assignment.participants

	end

	def OneAssignmentOneStudent

		@assignment = Assignment.find_by_id(params[:assignment_id])

		@participant = Participant.find_by_user_id(params[:user_id])

		@questionnaires = @assignment.questionnaires

		bar_1_data = [@participant.getAverageScore]

		bar_2_data = [@assignment.getAverageScore]

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

			bc.shape_marker :circle, :color => 'ffffff', :data_set_index => 0, :data_point_index => -1, :pixel_size => 10

			bc.shape_marker :circle, :color => '00ff00', :data_set_index => 1, :data_point_index => -1, :pixel_size => 10

			@bc= bc.to_url

		end

	end

	def AllAssignmentsOneStudent


	end

end
