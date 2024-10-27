require 'analytic/score_analytic'

class Answer < ApplicationRecord
  include ScoreAnalytic
  belongs_to :question
  belongs_to :response

  def self.answers_by_question_for_reviewee_in_round(assignment_id, reviewee_id, q_id, round)
    #  get all answers to this question
    question_answer = Answer.select(:answer, :comments)
                            .joins('join responses on responses.id = answers.response_id')
                            .joins('join response_maps on responses.map_id = response_maps.id')
                            .joins('join questions on questions.id = answers.question_id')
                            .where("response_maps.reviewed_object_id = ? and
                                           response_maps.reviewee_id = ? and
                                           answers.question_id = ? and
                                           responses.round = ?", assignment_id, reviewee_id, q_id, round)
    question_answer
  end

  def self.answers_by_question(assignment_id, q_id)
    question_answer = Answer.select('DISTINCT answers.comments,  answers.answer')
                            .joins('JOIN questions ON answers.question_id = questions.id')
                            .joins('JOIN responses ON responses.id = answers.response_id')
                            .joins('JOIN response_maps ON responses.map_id = response_maps.id')
                            .where('answers.question_id = ? and response_maps.reviewed_object_id = ?', q_id, assignment_id)
    question_answer
  end

  def self.answers_by_question_for_reviewee(assignment_id, reviewee_id, q_id)
    question_answers = Answer.select(:answer, :comments)
                             .joins('join responses on responses.id = answers.response_id')
                             .joins('join response_maps on responses.map_id = response_maps.id')
                             .joins('join questions on questions.id = answers.question_id')
                             .where("response_maps.reviewed_object_id = ? and
                                                 response_maps.reviewee_id = ? and
                                                 answers.question_id = ? ", assignment_id, reviewee_id, q_id)
    question_answers
  end
end
