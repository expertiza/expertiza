require 'gruff'

class ClassPerformanceController < ApplicationController
  def action_allowed?
    true
  end

  def select_rubrics
    assignment_id = params[:id]

    # Get the assignment object for the above ID and set the @assignment_name object for the view
    @assignment = Assignment.find(assignment_id)
    #@results = ActiveRecord::Base.connection.select_all('select a.txt from questions a , questionnaires b where a.questionnaire_id = b.id and a.questionnaire_id in ( select a.questionnaire_id from assignment_questionnaires a, questionnaires b, assignments c where a.assignment_id = c.id and a.questionnaire_id = b.id and b.type =\'ReviewQuestionnaire\' and c.id = #{assignment})')
    questionnaires = AssignmentQuestionnaire.where(assignment_id: assignment_id).pluck(:questionnaire_id)
    questionnaires = questionnaires - Questionnaire.where.not(type: 'ReviewQuestionnaire').pluck(:id)
    questionnaires = questionnaires.uniq {|questionnaire| questionnaire}

    @results = []
    @question_ids = []
    questionnaires.each do |questionnaire|
        questions = Question.where(questionnaire_id: questionnaire).to_a
        @results += questions
    end
  end

  def show_class_performance
    questions = params[:class_performance][:criterias]
    assignment_id = params[:id]

    chart_data = {}
    questions.each do |question_id|
        count = 0
        sum = 0
        if question_id.empty?
           next
        end
        response_maps = ResponseMap.where(reviewed_object_id: assignment_id, type: 'ReviewResponseMap').all
        if response_maps.blank?
            next
        end
        response_maps.each do |response_map| 
            responses = Response.where(map_id: response_map.id).all
            if responses.blank?
                next
            end
            responses.each do |response|
                answers = Answer.where(response_id: response.id, question_id: question_id).all
                if answers.blank?
                    next
                end
                answers.each do |answer|
                    if answer.blank? or answer.answer.blank?
                        next
                    end
                    count = count + 1
                    sum = sum + answer.answer
                end
            end
        end
        if count != 0
            chart_data[question_id] = sum.to_f / count
        end
    end

    graph = Gruff::Bar.new()
    graph.x_axis_label = "Rubrics"
    graph.y_axis_label = "Average class score"
    graph.title = "Class Performance"
    graph.sort = false
    graph.theme_37signals

    graph.data(0, 0)
    chart_data.each do |key, value|
        graph.data(key, value )
    end
    graph.write("app/assets/images/class_performance/chart.png")

    
  end
end
