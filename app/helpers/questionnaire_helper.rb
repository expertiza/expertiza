# OSS808 Change 28/10/2013
# FasterCSV replaced now by CSV which is present by default in Ruby
#require 'fastercsv'
#require 'csv'

module QuestionnaireHelper

  CSV_QUESTION = 0
  CSV_TYPE = 1
  CSV_PARAM = 2
  CSV_WEIGHT = 3

  def self.create_questionnaire_csv(questionnaire, user_name)
    csv_data = CSV.generate do |csv|
      for question in questionnaire.questions
        # Each row is formatted as follows
        # Question, question advice (from high score to low), type, weight
        row = Array.new
        row << question.txt
        if questionnaire.section != "Custom"
          row << "True/False" if question.true_false
          row << "Numeric" if !question.true_false
        else
          row << QuestionType.find_by_question_id(question.id).q_type
        end

        row << question.question_type.try(:parameters) || ''

        row << question.weight

        #if questionnaire.section == "Custom"
        #  row << QuestionType.find_by_question_id(question.id).parameters
        #else
        #  row << ""
        #end

        # loop through all the question advice from highest score to lowest score
        adjust_advice_size(questionnaire, question)
        for advice in question.question_advices.sort {|x,y| y.score <=> x.score }
          row << advice.advice
        end

        csv << row
    end
  end

  return csv_data
end

def self.get_questions_from_csv(questionnaire, file)
  questions = Array.new
  custom_rubric = questionnaire.section == "Custom"

  CSV::Reader.parse(file) do |row|
    if row.length > 0
      i = 0
      score = questionnaire.max_question_score
      q = Question.new

      q_type = QuestionType.new if custom_rubric

      q.true_false = false

      row.each do |cell|
        case i
        when CSV_QUESTION
          q.txt = cell.strip if cell != nil
        when CSV_TYPE
          if cell != nil
            q.true_false = cell.downcase.strip == Question::TRUE_FALSE.downcase
            q_type.q_type = cell.strip if custom_rubric
          end
        when CSV_PARAM
          if custom_rubric
            q_type.parameters = cell.strip if cell
          end
        when CSV_WEIGHT
          q.weight = cell.strip.to_i if cell
        else
          if score >= questionnaire.min_question_score and cell != nil
            a = QuestionAdvice.new(:score => score, :advice => cell.strip) if custom_rubric
            a = QuestionAdvice.new(:score => questionnaire.min_question_score + i - 4, :advice => cell.strip)
            score = score - 1
            q.question_advices << a
          end
        end

        i = i + 1
      end

      q.save

      q_type.question = q if custom_rubric
      q_type.save if custom_rubric

      questions << q
    end
  end

  questions
end

def self.adjust_advice_size(questionnaire, question)
  if question.true_false and question.question_advices.length != 2
    question.question_advices << QuestionAdvice.new(:score=>0)
    question.question_advices << QuestionAdvice.new(:score=>1)

    QuestionAdvice.delete_all(["question_id = ? AND (score > 1 OR score < 0)", question.id])
    return true
  elsif question.true_false == false
    for i in (questionnaire.min_question_score..questionnaire.max_question_score)
      print "\n#{i}: #{question.id}"
      qa = QuestionAdvice.where("question_id = #{question.id} AND score = #{i}").first

        if qa == nil
          print " NEW "
          question.question_advices << QuestionAdvice.new(:score=>i)
      end
    end

    QuestionAdvice.delete_all(["question_id = ? AND (score > ? OR score < ?)",
                               question.id, questionnaire.max_question_score, questionnaire.min_question_score])
    return true
  end

  return false
end

#quiz methods added in QuestionnaireHelper
#View a quiz questionnaire
def view_quiz
  @questionnaire = Questionnaire.find(params[:id])
  @participant = Participant.find(params[:pid]) #creating an instance variable since it needs to be sent to submitted_content/edit
  render :view
end

#save an updated quiz questionnaire to the database
def update_quiz
  @questionnaire = Questionnaire.find(params[:id])
  redirect_to controller: 'submitted_content', action: 'edit', id: params[:pid] if @questionnaire == nil
  if params['save']
    @questionnaire.update_attributes(params[:questionnaire])
    for qtypeid in params[:question_type].keys
      @question_type = QuestionType.find(qtypeid)
      @question_type.update_attributes(params[:question_type][qtypeid])
    end
    questionnum=1
    for qid in params[:new_question].keys
      @question = Question.find(qid)
      @question.update_attributes(params[:new_question][qid])
      @question_type = QuestionType.find_by_question_id(qid)
      @quiz_question_choices = QuizQuestionChoice.where(question_id: qid)
      i=1
      for quiz_question_choice in @quiz_question_choices
        if  @question_type.q_type!="Essay"
          if (@question_type.q_type=="MCC")
            mcc_check #check for MCC and update
          elsif (@question_type.q_type=="MCR")
            mcr_check #check for MCR and update
          elsif (@question_type.q_type=="TF")
            tf_check  #check for tf and update
          end
          i+=1
        end
      end
      questionnum+=1
    end
    # save
    #save_choices @questionnaire.id
  end
  redirect_to controller: 'submitted_content', action: 'edit', id: params[:pid]
end

def mcc_check
  if(params[:quiz_question_choices][questionnum.to_s][@question_type.q_type][i.to_s])
    if  params[:quiz_question_choices][questionnum.to_s][@question_type.q_type][i.to_s][:iscorrect]==1.to_s
      quiz_question_choice.update_attributes(iscorrect: '1', txt: params[:quiz_question_choices][quiz_question_choice.id.to_s][:txt])
    else
      quiz_question_choice.update_attributes(iscorrect: '0', txt: params[:quiz_question_choices][quiz_question_choice.id.to_s][:txt])
    end
  else
    quiz_question_choice.update_attributes(iscorrect: '0', txt: params[:quiz_question_choices][quiz_question_choice.id.to_s][:txt])
  end
end

def mcr_check
  if  params[:quiz_question_choices][questionnum.to_s][@question_type.q_type][1.to_s][:iscorrect]== i.to_s
    quiz_question_choice.update_attributes(iscorrect: '1', txt: params[:quiz_question_choices][quiz_question_choice.id.to_s][:txt])
  else
    quiz_question_choice.update_attributes(iscorrect: '0', txt: params[:quiz_question_choices][quiz_question_choice.id.to_s][:txt])
  end
end

def tf_check
  if  params[:quiz_question_choices][questionnum.to_s][@question_type.q_type][1.to_s][:iscorrect]== 1.to_s
    quiz_question_choice.update_attributes(iscorrect: '1', txt: "True")
  else
    quiz_question_choice.update_attributes(iscorrect: '1', txt: "False")
  end
end

#define a new quiz questionnaire
#method invoked by the view
def new_quiz
  @questionnaire = Object.const_get(params[:model]).new
  @questionnaire.private = params[:private]
  @questionnaire.min_question_score = 0
  @questionnaire.max_question_score = 1
  @participant_id = params[:pid] #creating an instance variable to hold the participant id
  @assignment_id = params[:aid] #creating an instance variable to hold the assignment id
  render :new_quiz
end

def validate_quiz
  num_quiz_questions = Assignment.find(params[:aid]).num_quiz_questions
  valid = "valid"

  (1..num_quiz_questions).each do |i|
    if params[:new_question][i.to_s][:txt] == ''
      #One of the questions text is not filled out
      valid = "Please make sure all questions have text"
      break
    elsif params[:question_type][i.to_s][:type] == nil
      #A type isnt selected for a question
      valid = "Please select a type for each question"
      break
    else
      type = params[:question_type][i.to_s][:type]
      if type == 'MCC' || type == 'MCR'
        validate_mcc_mcr
        unless correct_selected == true
          #A correct option isnt selected for a check box or radio question
          valid = "Please select a correct answer for all questions"
          break
        end
      elsif type == 'TF'
        if params[:new_choices][i.to_s]["TF"] == nil
          #A correct option isnt selected for a true/false question
          valid = "Please select a correct answer for all questions"
          break
        end
      end
    end
  end

  return valid
end

def validate_mcc_mcr
  correct_selected = false
  (1..4).each do |x|
    if params[:new_choices][i.to_s][type][x.to_s][:txt] == ''
      #Text isnt provided for an option
      valid = "Please make sure every question has text for all options"
      break
    elsif type == 'MCR' and not params[:new_choices][i.to_s][type][x.to_s][:iscorrect] == nil
      correct_selected = true
    elsif type == 'MCC' and not params[:new_choices][i.to_s][type][x.to_s][:iscorrect] == 0.to_s
      correct_selected = true
    end
  end
end
end