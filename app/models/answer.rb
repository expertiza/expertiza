require 'analytic/score_analytic'

class Answer < ApplicationRecord
  include ScoreAnalytic
  belongs_to :item
  belongs_to :response

  def self.answers_by_item_for_reviewee_in_round(assignment_id, reviewee_id, q_id, round)
    #  get all answers to this item
    item_answer = Answer.select(:answer, :comments)
                            .joins('join responses on responses.id = answers.response_id')
                            .joins('join response_maps on responses.map_id = response_maps.id')
                            .joins('join items on items.id = answers.item_id')
                            .where("response_maps.reviewed_object_id = ? and
                                           response_maps.reviewee_id = ? and
                                           answers.item_id = ? and
                                           responses.round = ?", assignment_id, reviewee_id, q_id, round)
    item_answer
  end

  def self.answers_by_item(assignment_id, q_id)
    item_answer = Answer.select('DISTINCT answers.comments,  answers.answer')
                            .joins('JOIN items ON answers.item_id = items.id')
                            .joins('JOIN responses ON responses.id = answers.response_id')
                            .joins('JOIN response_maps ON responses.map_id = response_maps.id')
                            .where('answers.item_id = ? and response_maps.reviewed_object_id = ?', q_id, assignment_id)
    item_answer
  end

  def self.answers_by_item_for_reviewee(assignment_id, reviewee_id, q_id)
    item_answers = Answer.select(:answer, :comments)
                             .joins('join responses on responses.id = answers.response_id')
                             .joins('join response_maps on responses.map_id = response_maps.id')
                             .joins('join items on items.id = answers.item_id')
                             .where("response_maps.reviewed_object_id = ? and
                                                 response_maps.reviewee_id = ? and
                                                 answers.item_id = ? ", assignment_id, reviewee_id, q_id)
    item_answers
  end
end
