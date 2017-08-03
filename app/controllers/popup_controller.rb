require 'httparty'
require 'json'
class PopupController < ApplicationController
  include HTTParty

  @sentiment_analysis={}
  @data_to_analyze = {}
  @review_comments_g = {} #set by assignment_sentiment_analysis_popup to be used in createQuestionWiseStructure
  @assignment_sentiment_view = false # Flag to indicate whether its overall sentiment analysis or per reviewer sentiment analysis
  def action_allowed?
    ['Super-Administrator',
     'Administrator',
     'Instructor',
     'Teaching Assistant'].include? current_role_name
  end

  # this can be called from "response_report" by clicking student names from instructor end.
  def author_feedback_popup
    @response_id = params[:response_id]
    @reviewee_id = params[:reviewee_id]
    unless @response_id.nil?
      first_question_in_questionnaire = Answer.where(response_id: @response_id).first.question_id
      questionnaire_id = Question.find(first_question_in_questionnaire).questionnaire_id
      questionnaire = Questionnaire.find(questionnaire_id)
      @maxscore = questionnaire.max_question_score
      @scores = Answer.where(response_id: @response_id)
      @response = Response.find(@response_id)
      @total_percentage = @response.get_average_score
      @sum = @response.get_total_score
      @total_possible = @response.get_maximum_score
    end

    @maxscore = 5 if @maxscore.nil?

    unless @response_id.nil?
      participant = Participant.find(@reviewee_id)
      @user = User.find(participant.user_id)
    end
  end

  # this can be called from "response_report" by clicking team names from instructor end.
  def team_users_popup
    @sum = 0
    logger.info params[:id]
    @team = Team.find(params[:id])
    @assignment = Assignment.find(@team.parent_id)
    @team_users = TeamsUser.where(team_id: params[:id])

    # id2 is a response_map id
    unless params[:id2].nil?
      participant_id = ResponseMap.find(params[:id2]).reviewer_id
      @reviewer_id = Participant.find(participant_id).user_id
      # get the last response in each round from response_map id
      (1..@assignment.num_review_rounds).each do |round|
        response = Response.where(map_id: params[:id2], round: round).last
        instance_variable_set('@response_round_' + round.to_s, response)
        next if response.nil?
        instance_variable_set('@response_id_round_' + round.to_s, response.id)
        instance_variable_set('@scores_round_' + round.to_s, Answer.where(response_id: response.id))
        questionnaire = Response.find(response.id).questionnaire_by_answer(instance_variable_get('@scores_round_' + round.to_s).first)
        instance_variable_set('@max_score_round_' + round.to_s, questionnaire.max_question_score ||= 5)
        total_percentage = response.get_average_score
        total_percentage += '%' if total_percentage.is_a? Float
        instance_variable_set('@total_percentage_round_' + round.to_s, total_percentage)
        instance_variable_set('@sum_round_' + round.to_s, response.get_total_score)
        instance_variable_set('@total_possible_round_' + round.to_s, response.get_maximum_score)
      end
    end
  end

  def participants_popup
    @sum = 0
    @count = 0
    @participantid = params[:id]
    @uid = Participant.find(params[:id]).user_id
    @assignment_id = Participant.find(params[:id]).parent_id
    @user = User.find(@uid)
    @myuser = @user.id
    @temp = 0
    @maxscore = 0

    if params[:id2].nil?
      @scores = nil
    else
      @reviewid = Response.find_by_map_id(params[:id2]).id
      @pid = ResponseMap.find(params[:id2]).reviewer_id
      @reviewer_id = Participant.find(@pid).user_id
      # @reviewer_id = ReviewMapping.find(params[:id2]).reviewer_id
      @assignment_id = ResponseMap.find(params[:id2]).reviewed_object_id
      @assignment = Assignment.find(@assignment_id)
      @participant = Participant.where(["id = ? and parent_id = ? ", params[:id], @assignment_id])

      # #3
      @revqids = AssignmentQuestionnaire.where(["assignment_id = ?", @assignment.id])
      @revqids.each do |rqid|
        rtype = Questionnaire.find(rqid.questionnaire_id).type
        if rtype == 'ReviewQuestionnaire'
          @review_questionnaire_id = rqid.questionnaire_id
        end
      end
      if @review_questionnaire_id
        @review_questionnaire = Questionnaire.find(@review_questionnaire_id)
        @maxscore = @review_questionnaire.max_question_score
        @review_questions = @review_questionnaire.questions
      end

      @scores = Answer.where(response_id: @reviewid)
      @scores.each do |s|
        @sum += s.answer
        @temp += s.answer
        @count += 1
      end

      @sum1 = (100 * @sum.to_f) / (@maxscore.to_f * @count.to_f)

    end
  end

  def view_review_scores_popup
    @reviewer_id = params[:reviewer_id]
    @assignment_id = params[:assignment_id]
    @review_final_versions = ReviewResponseMap.final_versions_from_reviewer(@reviewer_id)
  end

  # this can be called from "response_report" by clicking reviewer names from instructor end.
  def reviewer_details_popup
    @userid = Participant.find(params[:id]).user_id
    @user = User.find(@userid)
    @id = params[:assignment_id]
  end

  def get_review_comments_from_assignment(assignment)
    #Added by Rushi: for each reviewer's comment and total assignment comments
    if @assignment != assignment or @review_comments.nil?
      review_comments = @assignment.compute_reviews_comments
      @assignment = assignment
    end
    return review_comments
  end


  # @author: Rushi.Bhatt (Independent study)
  # Def: To create the Heatmap data structure
  # input - takes class variable @sentiment_analysis
  # output - Structure to create the heatmap chart
  def convert_to_heatmap_data(sentiment_analysis)
    #we need to convert for each reviewee i.e for each keys
    # here we dont have round data and user has clicked on individual reviewer, so
    #v_labels are all the reviewees
    #h_labels are all the questions,
    v_label_array =[]
    h_label_array =[]
    h_label_array_length=[]
    if @assignment_sentiment_view==false
      #individual reviewer view, when clicked on individual reviewer
      sentiment_analysis.each do |key,value|
        #map the reviewee id to the user id, using the participants table
        reviewee_id =   TeamsUser.find_by(:team_id=>key).user_id
        reviewee_name = User.find_by(:id => reviewee_id).name
        v_label_array.push(reviewee_name)
        h_label_array_length.push(value["sentiments"].length) #number of questions/answers in the data for each reviewer
      end
      max_hlabel_length = h_label_array_length.min #ideally all the values in the @h_label_array_length will be same
      for i in 0..max_hlabel_length-2         # -2 because last data is for additionalComments,and index starts from 0
        h_label_array.push("Q"+(i+1).to_s)
      end
      h_label_array.push("AdditionalComments")

    else
      #assignment overall view, when clicked on sentiment_analysis link
      sentiment_analysis.each do |key,value|
        #map the reviewer id to the user id, using the participants table
        reviewer_id =   Participant.find_by(:id => key).user_id
        reviewer_name = User.find_by(:id => reviewer_id).name
        v_label_array.push(reviewer_name)
        h_label_array = []
        h_label_array_length.push(value["sentiments"].length) if value.key?("sentiments")
      end

      h_label_array = []
      for i in 1..h_label_array_length.max   #for now, I have used min, but we can use max and use dummy data where data is not found
        h_label_array.push("Reviewee"+i.to_s) #Dummy label creation. actual reviewee id will be in the comment
      end
    end

    @jsonHeatmapDataArray = []
    @jsonHeatmapData = {
        "v_labels"=> v_label_array,
        "h_labels"=> h_label_array,
        "showTextInsideBoxes"=> true,
        "showCustomColorScheme"=> false,
        "tooltipColorScheme"=> "black",
        "font-size"=> 11,
        "font-face"=> "Arial",
        "custom_color_scheme"=> {"minimum_value"=> -1, "maximum_value"=> 1, "minimum_color"=> "#FFFF00", "maximum_color"=> "#FF0000", "total_intervals"=> 5},
        "color_scheme"=>
            { "ranges"=> [
                {"minimum"=> -1, "maximum"=> -0.5, "color"=> "#E74C3C"},
                {"minimum"=> -0.5, "maximum"=> 0, "color"=> "#F1948A"},
                {"minimum"=> 0, "maximum"=> 0.5, "color"=> "#82E0AA"},
                {"minimum"=> 0.5, "maximum"=> 1, "color"=> "#229954"}
            ]
            },
        "content"=> []
    }
    content_array=[]   #To set the content of above structure
    sentiment_analysis.each do |key,value|
      #Outer loop for each key
      eachRow = []
      for j in 0..@jsonHeatmapData["h_labels"].length-1
        eachCell={}
        if j < value["sentiments"].length
            eachCell["value"] = value["sentiments"][j]["sentiment"]
          if @assignment_sentiment_view==true
            reviewee_id =   TeamsUser.find_by(:team_id=>value["sentiments"][j]["id"].to_i).user_id
            reviewee_name = User.find_by(:id=>reviewee_id).name
            eachCell["text"] = "(" + reviewee_name + ") <= "+ value["sentiments"][j]["text"]  #adding the reviewee name to the data
          else
            eachCell["text"] = value["sentiments"][j]["text"]
          end
        else
          eachCell["text"] = "N/A"
          eachCell["value"] = 0
        end
        eachRow.push(eachCell)
      end
      content_array.push(eachRow)
    end
    @jsonHeatmapData["content"] = content_array
    return @jsonHeatmapData
  end

  # @author: Rushi.Bhatt (Independent study)
  # Def: To generate sentiment analysis for individual reviewer
  # input - takes class variable @review_comments_g
  def reviewer_sentiment_analysis_popup
    @assignment_sentiment_view=false  #Set the assignment flag to false, since its for individual reviewer
    @userid = Participant.find(params[:id]).user_id
    @user = User.find(@userid)
    @id = params[:assignment_id]
    @assignment = Assignment.find(params[:assignment_id])
    @rounds = @assignment.num_review_rounds
    @reviewer_id = AssignmentParticipant.find_by_user_id_and_assignment_id(@userid, @id).id

    @review_comments = get_review_comments_from_assignment(@assignment)

    #check if the assignment has rounds with varying rubrics or not
    if not @assignment.varying_rubrics_by_round?
      #Structure of the data - [reviewer_id][reviewee_id] = comments

      @w=0 #widht of the heatmap chart div
      @h=0 #height of the heatmap chart div
      @heatmapData={} #data for the heatmap chart

      #Get only the data for particular reviewer
      data_to_analyze = @review_comments[@reviewer_id] #Since we want to use that data in another function, we are storing it in class variable
      @analysis = analyze_review_comments_tone(data_to_analyze)
      @heatmapData = convert_to_heatmap_data(@analysis)
      @w = (@heatmapData['h_labels'].length ) * 200 + 100
      @w = (@w < 1000) ? @w : 1000
      @h = (@heatmapData['v_labels'].length + 1) * 80

    else
      #Multiple rounds
      #Structure of the data - [reviewer_id][round][reviewee_id] = comments
      #Do the same process above but for each round

      @heatmapData={} #data for the heatmap chart
      @w={} #widht of the heatmap chart div for each round
      @h={} #height of the heatmap chart div for each round

      for round in 1..@rounds do
        #[reviewer_id][reviewee_id] = comments
        #only the data for particular reviewer:
        data_to_analyze = @review_comments[@reviewer_id][round]
        @analysis = analyze_review_comments_tone(data_to_analyze)
        @heatmapDataForEachRound = convert_to_heatmap_data(@analysis)
        @heatmapData[round]=@heatmapDataForEachRound
        @wForEachRound = (@heatmapDataForEachRound['h_labels'].length ) * 200 + 100
        @hForEachRound = (@heatmapDataForEachRound['v_labels'].length + 1) * 80
        @w[round]=@wForEachRound
        @h[round]=@hForEachRound
      end #for loop
    end #if else
  end #def


  #@author - Rushi.Bhatt.
  #def - Creating question wise structure for assignment sentiment analysis report
  #structure: [questionX][reviewer_id]["reviews"]=>[ {id=reviewee_id, text= CommentforquestionX},{..}]
  #input - takes @review_comments_g class variable as an input
  def create_questionwise_structure(review_comments)
    @assignment = Assignment.find(params[:assignment_id])
    @rounds = @assignment.num_review_rounds
    if not @assignment.varying_rubrics_by_round?
      #if the assignment doesnt have any round wise structure
      @questionwiseStructure={}
      @num_of_questions_array=[]
      review_comments.each do |key,value|
        value.each do |key1,value1|
          @num_of_questions_array.push(value1["reviews"].length)
        end
      end
      @num_of_questions = @num_of_questions_array.max

      for @question_num in 0..@num_of_questions-1
        @eachQuestion={}
        review_comments.each do |reviewer,reviewee|
          @eachReviewer={}
          @eachRow = []
          reviewee.each do |key,value|
            @eachCell = {}
            @eachCell = value["reviews"][@question_num]
            @eachCell["id"] = key.to_s
            @eachCell["text"] = "-" if @eachCell["text"].nil?
            @eachRow.push(@eachCell)
          end
          @eachReviewer["reviews"] = @eachRow
          @eachQuestion[reviewer.to_s]=@eachReviewer
          if @question_num+1 == @num_of_questions     #last question is additional comment
            @key = "AdditionalComments"
          else
            @key = "Q"+(@question_num+1).to_s
          end
          @questionwiseStructure[@key] = @eachQuestion
        end
      end
      @questionwiseStructure
    else
      #assignment has rounds, each round might have different number of questions
      #[round][questionX][reviewer_id]["reviews"]=>[ {id=reviewee_id, text= CommentforquestionX},{..}]
      @questionwiseStructure={}
      @num_of_questions={}
      review_comments.each do |key,value|
        value.each do |key1,value1|
          value1.each do |key2,value2|
            @num_of_questions[key1]=(value2["reviews"].length)
          end
        end
      end

      for @round_num in 1..@rounds
        @eachRound = {}
        for @question_num in 0..@num_of_questions[@round_num]-1
          @eachQuestion={}
          review_comments.each do |reviewer,reviewer_value|
            @eachReviewer={}
            @eachRow = []
            reviewer_value[@round_num].each do |reviewee,reviewee_value|
              @eachCell = {}
              @eachCell = reviewee_value["reviews"][@question_num]
              @eachCell["id"] = reviewee.to_s
              @eachCell["text"] = "-" if @eachCell["text"].nil?
              @eachRow.push(@eachCell)
            end #for each reviewee
            @eachReviewer["reviews"] = @eachRow
            @eachQuestion[reviewer.to_s]=@eachReviewer
          end  #for each reviewer

          if @question_num+1 == @num_of_questions[@round_num] then    #last question is additional comment
            @key = "AdditionalComments"
          else
            @key = "Q"+(@question_num+1).to_s
          end
          @eachRound[@key] = @eachQuestion
        end #for each question
        @questionwiseStructure[@round_num] = @eachRound
      end #for each round
      @questionwiseStructure
    end #if else
  end #def

  # @author: Rushi.Bhatt (Independent study)
  # Def: To generate sentiment analysis for overall assignment
  # input - takes class variable @review_comments_g
  def assignment_sentiment_analysis_popup
    @assignment_sentiment_view=true  #set the assignment sentiment analysis flag to true
    @assignment = Assignment.find(params[:assignment_id])
    @review_comments = get_review_comments_from_assignment(@assignment)
    @rounds = @assignment.num_review_rounds
    @num_of_questions={}
    if not @assignment.varying_rubrics_by_round?
      @review_comments.each do |key,value|
        value.each do |key2,value2|
          @num_of_questions[key]=(value2["reviews"].length)
        end
      end
    else
      @review_comments.each do |key,value|
        value.each do |key1,value1|
          value1.each do |key2,value2|
            @num_of_questions[key1]=(value2["reviews"].length)
          end
        end
      end
    end

    @review_comments = create_questionwise_structure(@review_comments)
    if not @assignment.varying_rubrics_by_round?
      @w={}
      @h={}
      @heatmapData={}
      for question in 1..@num_of_questions
        #[reviewer_id][reviewee_id] = comments
        #only the data for particular reviewer:
        if question == @num_of_questions  #last question is addditionalComment
          data_to_analyze = @review_comments["AdditionalComments"]
        else
          data_to_analyze = @review_comments["Q"+question.to_s]
        end
        @analysis = analyze_review_comments_tone(data_to_analyze)
        @heatmapDataForEach = convert_to_heatmap_data(@analysis)
        @wForEach = (@heatmapDataForEach['h_labels'].length ) * 200 + 100
        @hForEach = (@heatmapDataForEach['v_labels'].length + 1) * 80

        if question == @num_of_questions
          @heatmapData["AdditionalComments"]=@heatmapDataForEach
          @w["AdditionalComments"]=@wForEach
          @h["AdditionalComments"]=@hForEach
        else
          @heatmapData[question]=@heatmapDataForEach
          @w[question]=@wForEach
          @h[question]=@hForEach
        end
      end
    else
      #multiple rounds
      @heatmapData={}
      @w={}
      @h={}
      for round in 1..@rounds do
        @heatmapData[round]={}
        @w[round]={}
        @h[round]={}
        for question in 1..@num_of_questions[round]
          #[reviewer_id][reviewee_id] = comments
          #only the data for particular reviewer:
          if question == @num_of_questions[round]  #last question is addditionalComment
            data_to_analyze = @review_comments[round]["AdditionalComments"]
          else
            data_to_analyze = @review_comments[round]["Q"+question.to_s]
          end

          @analysis = analyze_review_comments_tone(data_to_analyze)
          @heatmapDataForEach = convert_to_heatmap_data(@analysis)
          @wForEach = (@heatmapDataForEach['h_labels'].length ) * 200 + 100
          @hForEach = (@heatmapDataForEach['v_labels'].length + 1) * 80

          if question == @num_of_questions[round]
            @heatmapData[round]["AdditionalComments"]=@heatmapDataForEach
            @w[round]["AdditionalComments"]=@wForEach
            @h[round]["AdditionalComments"]=@hForEach
          else
            @heatmapData[round][question]=@heatmapDataForEach
            @w[round][question]=@wForEach
            @h[round][question]=@hForEach
          end
        end # for loop for question
      end #for loop for round
    end #for if else
  end #def

  # @author: Rushi.Bhatt (Independent study)
  # Def: To analyze the review coomments using the sentiment analysis service - peer logic
  # input - takes class variable data_to_analyze
  def analyze_review_comments_tone (data_to_analyze)
    analyzedData = {}
    data_to_analyze.each do |key,value|
      result = HTTParty.post("http://peerlogic.csc.ncsu.edu/sentiment/analyze_reviews_bulk",
                              :body => value.to_json,
                              :headers => { 'Content-Type' => 'application/json' })
      analyzedData[key]=result
    end
    return analyzedData
  end

end
