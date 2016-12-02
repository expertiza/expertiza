require 'gruff'

class ClassPerformanceController < ApplicationController
  def action_allowed?
    true
  end

  def select_rubrics
    @assignment_id = params[:id]

    # Get the assignment object for the above ID and set the @assignment_name object for the view
    @assignment = Assignment.find(@assignment_id)
    #@results = ActiveRecord::Base.connection.select_all('select a.txt from questions a , questionnaires b where a.questionnaire_id = b.id and a.questionnaire_id in ( select a.questionnaire_id from assignment_questionnaires a, questionnaires b, assignments c where a.assignment_id = c.id and a.questionnaire_id = b.id and b.type =\'ReviewQuestionnaire\' and c.id = #{assignment})')
    #puts @results
    questionnaires = AssignmentQuestionnaire.where(assignment_id: @assignment_id).pluck(:questionnaire_id)
    questionnaires = questionnaires - Questionnaire.where.not(type: 'ReviewQuestionnaire').pluck(:id)
    questionnaires = questionnaires.uniq {|questionnaire| questionnaire}

    @results = []
    @question_ids = []
    questionnaires.each do |questionnaire|
        questions = Question.where(questionnaire_id: questionnaire).to_a
        @results += questions
    end
  
    @questions = []
    #@selections = []
    @results.each do |result|
     # puts result.txt
      
    #    @question_ids.push(result.id) unless @question_ids.include?(result.id)
    #    @selections[result.id] = "0"
    end
  end

  def show_class_performance
    raise SystemError
    line_chart = Gruff::Bar.new()
    line_chart.labels = {0=>'Value (USD)'}
    line_chart.title = "My Guitar Collection"

    {"'70 Strat"=>2500, 
     "'69 Tele"=>2000,
     "'02 Modded Mexi Strat Squier"=>400}.each do |guitar, value| 
        line_chart.data(guitar, value )
    end
    line_chart.write("app/assets/images/class_performance/chart.png")
  end
end
