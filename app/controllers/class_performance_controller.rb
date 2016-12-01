class ClassPerformanceController < ApplicationController
  def action_allowed?
    true
  end

  def select_rubrics
  @results = ActiveRecord::Base.connection.select_all('select a.questionnaire_id, a.txt , b.name from questions a , questionnaires b     where a.questionnaire_id = b.id and a.questionnaire_id in ( select a.questionnaire_id from assignment_questionnaires a, que    stionnaires b, assignments c where a.assignment_id = c.id and a.questionnaire_id = b.id and b.type =\'ReviewQuestionnaire\'     and c.id = 772)')

    #ActiveRecord::Base.connection.select_all('select a.questionnaire_id, a.txt , b.name from questions a , questionnaires b where a.questionnaire_id = b.id and a.questionnaire_id in ( select a.questionnaire_id from assignment_questionnaires a, questionnaires b, assignments c where a.assignment_id = c.id and a.questionnaire_id = b.id and b.type =\'ReviewQuestionnaire\' and c.id = 772)').each do |e|
     #   puts e.inspect
    #end

  end

  def show_class_performance
  end
end
