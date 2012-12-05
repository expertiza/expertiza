class MineReviewDataController < ApplicationController
  require 'google_chart'
  REVIEW_GRAPHS = ["Review : Question Text And Review Comments Vs Assignments",
                   "Review : Questions Count And Review Comments Vs Assignments",
                   "Review : Sub Questions Count And Review Comments Vs Assignments",
                   "Average Review Parameters And Student Experience Vs Assignments",
                   "Average Metareview Parameters And Student Experience Vs Assignments",
                   "Assignment Strategy And Review Parameters Vs Assignments"]

  #color constants used throughout the page to maintain consistency. Add to this in order to add more colors to the graphs (if required)
  COLOR_1 = '9A0000'
  COLOR_2 = '0000ff'
  COLOR_3 = '008000'
  COLOR_4 = 'ff4500'

  #Draws a bar graph with the given data sets.
  def draw_bar_graph(graph, data_set1, data_set2 , assignment_names,data_set1_name , data_set2_name)
    max1 =0
    max2 =0
    #maximum values from both data sets are determined in order to determine the maximum value for the range of y axis
    if data_set1
      max1 = data_set1.max
    end
    if data_set2
      max2 = data_set2.max
    end
    @dataset_names = [[data_set1_name,'#'+COLOR_1+';'], [data_set2_name,'#'+COLOR_2+';']]
    @chart1 = GoogleChart::BarChart.new('1000x300', "" , :vertical, false) do |bc|
      #set the data sets whose values are to be displayed on the y axis
      bc.data data_set1_name, data_set1, COLOR_1
      bc.data data_set2_name, data_set2, COLOR_2
      bc.axis :y, :range => [0,[max1, max2].max], :color => '000000', :font_size => 12, :alignment => :center
      #set the labels for the assignments to be shown on the x axis
      bc.axis :x, :labels => Array.new(assignment_names.length){|i| i+1}, :color => '000000', :font_size => 12, :alignment => :center
      bc.show_legend = false
      bc.stacked = false
      bc.width_spacing_options :bar_width=> 10
      bc.shape_marker :circle, :color => COLOR_1, :data_set_index => 0, :data_point_index => -1, :pixel_size => 5
      bc.shape_marker :circle, :color => COLOR_2, :data_set_index => 1, :data_point_index => -1, :pixel_size => 5
    end
  end

  #Generates a dynamic table for the data in the given data sets
  def generate_table(name, data_set1, data_set2 , data_set3, data_set4 , assignment_names,data_set1_name , data_set2_name, data_set3_name, data_set4_name )
    table = "#{name}"

    table << "<br/><table border='1' align='left'>"

    table << "<tr><td></td>"
    assignment_names.each_with_index do |assignment,index|
      table << "<td>(#{index+1})#{assignment}</td>"
    end

    color = '#'+COLOR_1+';'
    table << "</tr><tr><td style='color:#{color}'>#{data_set1_name}</td>"
    data_set1.each do |value|
      table << "<td>#{value}</td>"
    end

    color = '#'+COLOR_2+';'
    table << "</tr><tr><td style='color:#{color}'>#{data_set2_name}</td>"
    data_set2.each do |value|
      table << "<td>#{value}</td>"
    end

    if(data_set3)
      color = '#'+COLOR_3+';'
      table << "</tr><tr><td style='color:#{color}'>#{data_set3_name}</td>"
      data_set3.each do |value|
        table << "<td>#{value}</td>"
      end
    end

    if(data_set4)
      color = '#'+COLOR_4+';'
      table << "</tr><tr><td style='color:#{color}'>#{data_set4_name}</td>"
      data_set4.each do |value|
        table << "<td>#{value}</td>"
      end
    end

    table << "</tr></table>"
    @table = table
  end

  #Draws a line graph for the data in the given data sets
  def draw_line_graph(graph, data_set1, data_set2, data_set3, data_set4 , assignment_names,data_set1_name , data_set2_name, data_set3_name, data_set4_name)
    @chart1 = GoogleChart::LineChart.new('800x200', "" , false) do |lc|
      #set the data sets whose values are to be displayed on the y axis
      lc.data data_set1_name, data_set1, COLOR_1
      lc.data data_set2_name, data_set2, COLOR_2
      #set the labels for the assignments to be shown on the x axis
      lc.axis :x, :labels => Array.new(assignment_names.length){|i| i+1}, :color => '000000', :font_size => 12,:alignment => :center
      lc.show_legend = true
      lc.shape_marker :circle, :color => COLOR_1, :data_set_index => 0, :data_point_index => -1, :pixel_size => 5
      lc.shape_marker :circle, :color => COLOR_2, :data_set_index => 1, :data_point_index => -1, :pixel_size => 5
      @dataset_names = [[data_set1_name,'#'+COLOR_1+';'], [data_set2_name,'#'+COLOR_2+';']]
      if(data_set3 and data_set4)
        #In order to compare the review parameters to determine the student experience we would need four markers instead of the usual two comparisons
        #Add the additional data sets and data set name details to the graph properties
        lc.data data_set3_name, data_set3, COLOR_3
        lc.shape_marker :circle, :color => COLOR_3, :data_set_index => 2, :data_point_index => -1, :pixel_size => 5
        lc.data data_set4_name, data_set4, COLOR_4
        lc.axis :y, :range => [0,[data_set1.max, data_set2.max, data_set3.max, data_set4.max].max], :font_size => 12, :alignment => :center
        lc.shape_marker :circle, :color => COLOR_4, :data_set_index => 3, :data_point_index => -1, :pixel_size => 5

        @dataset_names = @dataset_names + [[data_set3_name,'#'+COLOR_3+';'], [data_set4_name,'#'+COLOR_4+';']]
      elsif(data_set3)
        #In order to compare the metareview parameters to determine the student experience we would need three markers instead of the usual two comparisons
        #Add the additional data set and data set name details to the graph properties
        lc.data data_set3_name, data_set3, COLOR_3
        lc.axis :y, :range => [0,[data_set1.max, data_set2.max, data_set3.max].max], :font_size => 12, :alignment => :center
        lc.shape_marker :circle, :color => COLOR_3, :data_set_index => 2, :data_point_index => -1, :pixel_size => 5

        @dataset_names = @dataset_names + [[data_set3_name,'#'+COLOR_3+';']]
      else
        lc.axis :y, :range => [0,[data_set1.max, data_set2.max].max], :font_size => 12, :alignment => :center
      end
    end
  end

  #Fetches data for the average number of tokens in review comments and review questionnaire for given review type
  def question_text_and_review_comments_vs_assignments(assignments_for_graph)
    review_comments_data =[]
    review_questions_data =[]
    assignment_names=[]
    index = 0
    assignments_for_graph.each do |assignment|
      #get_review_comments will return all the review comments for each assignment if it belongs to one of the mentioned review response types
      comments = assignment.get_review_comments(["TeamReviewResponseMap","ParticipantReviewResponseMap","ReviewResponseMap"])
      #average_tokens finds the average number of unique tokens in the review comments in all the reviews put together
      review_comments_data[index] = assignment.average_tokens(comments)

      #get_review_questions will return all the review questions for each assignment if it belongs to the mentioned questionnaire type.
      questions = assignment.get_review_questions("ReviewQuestionnaire")
      #average_tokens finds the average number of tokens in questionnaires
      review_questions_data[index] = assignment.average_tokens(questions)

      assignment_names[index]=assignment.name

      index = index+1
    end
    [review_questions_data,review_comments_data,assignment_names]
  end

  #Fetches data for the number of questions in the questionnaires and average review comments length for a given review response type
  def questions_count_and_review_comments_vs_assignments(assignments_for_graph)
    review_comments_data =[]
    questions_data =[]
    assignment_names=[]
    index = 0
    assignments_for_graph.each do |assignment|

      comments = assignment.get_review_comments(["TeamReviewResponseMap","ParticipantReviewResponseMap","ReviewResponseMap"])
      review_comments_data[index] = assignment.average_tokens(comments)

      #count_questions fetches the number of questions of given questionnaire type.
      questions_data[index] = assignment.count_questions("ReviewQuestionnaire")

      assignment_names[index]=assignment.name

      index = index+1
    end
    [review_comments_data,questions_data,assignment_names]
  end

  #Fetches the average number of sub questions in a questionnaire and the associated average length of review content for a given response type
  def sub_questions_count_and_review_comments_vs_assignments(assignments_for_graph)
    avg_tokens_data =[]
    avg_subquestions_data =[]
    assignment_names=[]
    index = 0
    assignments_for_graph.each do |assignment|

      comments = assignment.get_review_comments(["TeamReviewResponseMap","ParticipantReviewResponseMap","ReviewResponseMap"])
      avg_tokens_data[index] = assignment.average_tokens(comments)

      #count_average_subquestions fetches the average number of subquestions in questionnaires of given type
      avg_subquestions_data[index] = assignment.count_average_subquestions("ReviewQuestionnaire")

      assignment_names[index]=assignment.name

      index = index+1
    end
    [avg_tokens_data,avg_subquestions_data,assignment_names]
  end

  #Fetches the review parameters associated with deducing gain in student expertise
  def average_reviews_parameters_and_student_experience_vs_assignments(assignments_for_graph)
    avg_num_of_reviews_data =[]
    avg_review_score_data =[]
    avg_token_count_data = []
    avg_fb_score_data = []
    assignment_names=[]
    index = 0
    assignments_for_graph.each do |assignment|

      #get_average_num_of_reviews fetches the average number of reviews across the given response types for a given assignment
      num_of_reviews = assignment.get_average_num_of_reviews(["TeamReviewResponseMap","ParticipantReviewResponseMap","ReviewResponseMap"])
      avg_num_of_reviews_data[index] = num_of_reviews

      #get_average_score_with_type fetches the average score provided for the reviews of given response type for an assignment
      avg_score = assignment.get_average_score_with_type(["TeamReviewResponseMap","ParticipantReviewResponseMap","ReviewResponseMap"])
      avg_review_score_data[index] = avg_score

      comments = assignment.get_review_comments(["TeamReviewResponseMap","ParticipantReviewResponseMap","ReviewResponseMap"])
      avg_token_count_data[index] = assignment.average_tokens(comments)

      #fetches the average score for feedback on reviews performed on reviews for the given assignment.
      avg_fb_score = assignment.get_average_score_with_type(["FeedbackResponseMap"])
      avg_fb_score_data[index] = avg_fb_score

      assignment_names[index]=assignment.name

      index = index+1
    end
    [avg_num_of_reviews_data,avg_review_score_data,avg_token_count_data, avg_fb_score_data, assignment_names]
  end

  #Fetches the metareview parameters associated with deducing gain in student expertise
  def average_metareviews_parameters_and_student_experience_vs_assignments(assignments_for_graph)
    avg_num_of_reviews_data =[]
    avg_metareview_score_data =[]
    avg_num_of_tokens_data = []
    assignment_names=[]
    index = 0
    assignments_for_graph.each do |assignment|

      num_of_reviews = assignment.get_average_num_of_metareviews(["TeamReviewResponseMap","ParticipantReviewResponseMap","ReviewResponseMap"])
      avg_num_of_reviews_data[index] = num_of_reviews

      #get_average_metareview_score_with_type fetches the average score provided for the reviews of reviews for an assignment
      avg_score = assignment.get_average_metareview_score_with_type(["TeamReviewResponseMap","ParticipantReviewResponseMap","ReviewResponseMap"])
      avg_metareview_score_data[index] = avg_score

      avg_num_of_tokens_data[index] = assignment.get_average_metareview_comments_with_type(["TeamReviewResponseMap","ParticipantReviewResponseMap","ReviewResponseMap"])


      assignment_names[index]=assignment.name

      index = index+1
    end
    [avg_num_of_reviews_data,avg_metareview_score_data,avg_num_of_tokens_data, assignment_names]
  end

  #Fetches the average review content for a given review assignment strategy
  def average_review_content_for_review_strategy_vs_assignments(assignments_for_graph)
    avg_review_content_data = []
    avg_num_of_reviews_data = []
    index = 0

    num_of_auto_review_assignments = 0
    num_of_auto_reviews = 0
    auto_review_content = 0
    num_of_instructor_reviews_assignments = 0
    num_of_instructor_reviews = 0
    instructor_review_content = 0
    num_of_student_reviews_assignments = 0
    num_of_student_reviews = 0
    student_review_content = 0

    assignments_for_graph.each do |assignment|
      if(assignment.review_assignment_strategy == "Auto-Selected")
        num_of_auto_review_assignments = num_of_auto_review_assignments + 1
        num_of_auto_reviews = num_of_auto_reviews + assignment.get_average_num_of_reviews(["TeamReviewResponseMap","ParticipantReviewResponseMap","ReviewResponseMap"])
        comments = assignment.get_review_comments(["TeamReviewResponseMap","ParticipantReviewResponseMap","ReviewResponseMap"])
        auto_review_content = auto_review_content + assignment.average_tokens(comments)
      elsif(assignment.review_assignment_strategy == "Instructor-Selected")
        num_of_instructor_reviews_assignments = num_of_instructor_reviews_assignments + 1
        num_of_instructor_reviews = num_of_instructor_reviews + assignment.get_average_num_of_reviews(["TeamReviewResponseMap","ParticipantReviewResponseMap","ReviewResponseMap"])
        comments = assignment.get_review_comments(["TeamReviewResponseMap","ParticipantReviewResponseMap","ReviewResponseMap"])
        instructor_review_content = instructor_review_content + assignment.average_tokens(comments)
      elsif(assignment.review_assignment_strategy == "Student-Selected")
        num_of_student_reviews_assignments = num_of_student_reviews_assignments + 1
        num_of_student_reviews = num_of_student_reviews + assignment.get_average_num_of_reviews(["TeamReviewResponseMap","ParticipantReviewResponseMap","ReviewResponseMap"])
        comments = assignment.get_review_comments(["TeamReviewResponseMap","ParticipantReviewResponseMap","ReviewResponseMap"])
        student_review_content = student_review_content + assignment.average_tokens(comments)
      end
    end

    if(num_of_auto_review_assignments!=0)
      avg_num_of_reviews_data[0] = ((num_of_auto_reviews/num_of_auto_review_assignments.to_f)*100).round / 100.0
      avg_review_content_data[0] = ((auto_review_content/num_of_auto_review_assignments.to_f)*100).round / 100.0

    else
      avg_num_of_reviews_data[0] = 0
      avg_review_content_data[0] = 0
    end


    if(num_of_instructor_reviews_assignments!=0)
      avg_num_of_reviews_data[1] = ((num_of_instructor_reviews/num_of_instructor_reviews_assignments.to_f)*100).round / 100.0
      avg_review_content_data[1] = ((instructor_review_content/num_of_instructor_reviews_assignments.to_f)*100).round / 100.0

    else
      avg_num_of_reviews_data[1] = 0
      avg_review_content_data[1] = 0
    end

    if(num_of_student_reviews_assignments!=0)
      avg_num_of_reviews_data[2] = ((num_of_student_reviews/num_of_student_reviews_assignments.to_f)*100).round / 100.0
      avg_review_content_data[2] = ((student_review_content/num_of_student_reviews_assignments.to_f)*100).round / 100.0

    else
      avg_num_of_reviews_data[2] = 0
      avg_review_content_data[2] = 0
    end
    @xaxis_legend=["Auto-selected","Instructor-selected","Student-selected"]
    [avg_num_of_reviews_data, avg_review_content_data,@xaxis_legend]
  end

  #Calls the above implemented methods in order to load data in the data sets for the respective graphs
  def populate_data_sets(assignments_for_graph,selected_graph)
    dataset1 =[]
    dataset2 =[]
    dataset3 =[]
    dataset4 =[]
    assignment_names=[]

    #store the names for the respective data sets for each line/bar depicted in the graph
    dataset1_name="", dataset2_name="", dataset3_name="", dataset4_name=""

    #case by case graphs represented for the type of graph selected in the dropdown
    if selected_graph
      index = REVIEW_GRAPHS.index(selected_graph)
      if index
        case index
          when 0
            dataset1_name="Average Unique Tokens in the Review Questions"
            dataset2_name="Average Unique Tokens in the Review Comments"
            dataset3_name=""
            dataset4_name=""
            dataset3=nil
            dataset4=nil
            dataset1,dataset2, assignment_names = question_text_and_review_comments_vs_assignments(assignments_for_graph)
          when 1
            dataset1_name="Average Unique Tokens in the Review Comments"
            dataset2_name="Number of Questions per Assignment"
            dataset3_name=""
            dataset4_name=""
            dataset3=nil
            dataset4=nil
            dataset1,dataset2, assignment_names = questions_count_and_review_comments_vs_assignments(assignments_for_graph)
          when 2
            dataset1_name="Average Unique Tokens in the Review Comments"
            dataset2_name="Average Number of Sub-questions per question"
            dataset3_name=""
            dataset4_name=""
            dataset3=nil
            dataset4=nil
            dataset1,dataset2, assignment_names = sub_questions_count_and_review_comments_vs_assignments(assignments_for_graph)
          when 3
            dataset1_name="Average Number of Reviews per student"
            dataset2_name="Average Score Percentage for Reviews"
            dataset3_name="Average Unique Tokens in the Review Comments"
            dataset4_name="Average Author Feedback Score"
            dataset1,dataset2,dataset3, dataset4, assignment_names = average_reviews_parameters_and_student_experience_vs_assignments(assignments_for_graph)
          when 4
            dataset1_name="Average Number of Metareviews"
            dataset2_name="Average Score Percentage for Metareviews"
            dataset3_name="Average Unique Tokens in the Metareview Comments"
            dataset4_name=""
            dataset4=nil
            dataset1,dataset2,dataset3, assignment_names = average_metareviews_parameters_and_student_experience_vs_assignments(assignments_for_graph)
          when 5
            dataset1_name="Average Number of Reviews for Given Strategy"
            dataset2_name="Average Review Content for Given Strategy"
            dataset3_name=""
            dataset4_name=""
            dataset3=nil
            dataset4=nil
            dataset1, dataset2, assignment_names = average_review_content_for_review_strategy_vs_assignments(assignments_for_graph)
        end
      end
    end
    [dataset1, dataset2, dataset3, dataset4, assignment_names, dataset1_name, dataset2_name, dataset3_name, dataset4_name]
  end

  #landing page action for this controller
  def view_review_charts
    @courses = Course.all #pertaining to one instructor
                          #stores the list of all graphs being represented on the page
    @review_graphs = REVIEW_GRAPHS

    @selected_course = nil
    @selected_graph = nil

    display = params[:display]
    if params[:course_list]
      @course_list = params[:course_list]
    else
      @course_list = []
    end

    if display and display[:graph_type] and !display[:graph_type].empty?
      @selected_graph = display[:graph_type]
    else
      @selected_graph = params[:graph_type]
    end
    if display and display[:course] and !display[:course].empty?
      @selected_course = display[:course]
    else
      @selected_course = params[:course_id]
    end

    #check if the selected course from the dropdown is part of the list. If the course does not already exist, add it to the list.
    if !@course_list.include?(@selected_course)
      @course_list << @selected_course
    end

    if @selected_graph and @selected_course
      @assignments = Hash.new

      @course_list.each do |course|
        @assignments[course] = Assignment.get_assignments_for_course(course)
      end

      assignments_for_graph = []

      if params[:assignment_ids] then
        assignments_for_graph = []
        params[:assignment_ids].each do |id|
          assignments_for_graph << Assignment.find_by_id(id)
        end
      else
        @assignments.each do |course,assignments|
          assignments.each do |assignment|
            assignments_for_graph << assignment
          end
        end
      end

      @selected_assignments = assignments_for_graph

      #fetch the required data sets for the graph selected from the drop down and populate the data sets
      #call the appropriate graph rendering functions and the function that will render the table for the given data sets
      if assignments_for_graph and !assignments_for_graph.empty? then

        dataset1, dataset2, dataset3, dataset4, assignment_names, dataset1_name, dataset2_name, dataset3_name, dataset4_name =populate_data_sets(assignments_for_graph, @selected_graph)
        #draw_line_graph(@selected_graph, dataset1, dataset2, assignment_names, dataset1_name, dataset2_name)
        if(dataset3)
          if(dataset4)
            draw_line_graph(@selected_graph, dataset1, dataset2,dataset3, dataset4, assignment_names, dataset1_name, dataset2_name, dataset3_name, dataset4_name)
            generate_table(@selected_graph, dataset1, dataset2,dataset3, dataset4, assignment_names, dataset1_name, dataset2_name, dataset3_name, dataset4_name)
          else
            draw_line_graph(@selected_graph, dataset1, dataset2, dataset3, nil, assignment_names, dataset1_name, dataset2_name, dataset3_name, "")
            generate_table(@selected_graph, dataset1, dataset2, dataset3, nil, assignment_names, dataset1_name, dataset2_name, dataset3_name, "")
          end
        else
          draw_bar_graph(@selected_graph, dataset1, dataset2, assignment_names, dataset1_name, dataset2_name)
          generate_table(@selected_graph, dataset1, dataset2, nil, nil, assignment_names, dataset1_name, dataset2_name, "", "")
        end
      end
    end
  end

  #fetches the course name for a given course_id
  def get_course_name(course_id)
    course = Course.find_all_by_id(course_id).first
    if course
      course.name
    else
      ""
    end
  end
end