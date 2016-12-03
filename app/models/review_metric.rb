class ReviewMetric < ActiveRecord::Base
	belongs_to :response_map, class_name: 'ResponseMap', foreign_key: 'response_id'
    attr_accessor :volume, :integer
    attr_accessor :suggestion, :boolean
    attr_accessor :problem, :boolean
    attr_accessor :offensive_term, :boolean

    def self.check_suggestion(reviewer_id,assignment_id)
    end

    def self.check_offensive_term(reviewer_id,assignment_id)
    	
    end

    def self.check_problem(reviewer_id,assignment_id)

	 problem_words = Set.new(["wrong","error","problem"])
       comments = ''
       counter = 0
       @comments_in_round_1, @comments_in_round_2, @comments_in_round_3 = '', '', ''
       @counter_in_round_1, @counter_in_round_2, @counter_in_round_3 = 0, 0, 0
       problem_in_round_1 = 0
       problem_in_round_2 = 0
       problem_in_round_3 = 0

comments, counter,comments_in_round_1, counter_in_round_1,comments_in_round_2, counter_in_round_2,comments_in_round_3, counter_in_round_3 = Response.concatenate_all_review_comments(assignment_id, reviewer_id,response_id=0)

      comments_in_round_1.split(' ').each do |word|
          if problem_words.include? word
          problem_in_round_1 = problem_in_round_1 + 1
        end
        end

       comments_in_round_2.split(' ').each do |word|
           if problem_words.include? word
             problem_in_round_2 = problem_in_round_2 + 1
	   end
           end

       comments_in_round_3.split(' ').each do |word|
           if problem_words.include? word
             problem_in_round_3 = problem_in_round_3 + 1
	   end
           end
       problem_percentage = 1
       problem = true
      [problem_percentage, problem_in_round_1, problem_in_round_2, problem_in_round_3]
    end


    def self.get_review_summary(reviewer_id,assignment_id)
    end

    def self.get_word_count(reviewer_id,assignment_id)
    end
 
def self.concatenate_all_review_comments(assignment_id, reviewer_id, response_id = 0)
    comments = ''
    counter = 0
    @comments_in_round_1, @comments_in_round_2, @comments_in_round_3 = '', '', ''
    @counter_in_round_1, @counter_in_round_2, @counter_in_round_3 = 0, 0, 0
    assignment = Assignment.find(assignment_id)
    question_ids = Question.get_all_questions_with_comments_available(assignment_id)

    ReviewResponseMap.where(reviewed_object_id: assignment_id, reviewer_id: reviewer_id).each do |response_map|
      (1..assignment.num_review_rounds).each do |round|
        last_response_in_current_round = response_map.response.select{|r| r.round == round }.last
        unless last_response_in_current_round.nil?
          last_response_in_current_round.scores.each do |answer|
            comments += answer.comments if question_ids.include? answer.question_id
            instance_variable_set('@comments_in_round_' + round.to_s, instance_variable_get('@comments_in_round_' + round.to_s) + answer.comments ||= '')
          end
          additional_comment = last_response_in_current_round.additional_comment
          comments += additional_comment
          counter += 1
          instance_variable_set('@comments_in_round_' + round.to_s, instance_variable_get('@comments_in_round_' + round.to_s) + additional_comment)
          instance_variable_set('@counter_in_round_' + round.to_s, instance_variable_get('@counter_in_round_' + round.to_s) + 1)
        end
      end
    end
    [comments, counter,
     @comments_in_round_1, @counter_in_round_1,
     @comments_in_round_2, @counter_in_round_2,
     @comments_in_round_3, @counter_in_round_3]
  end
end
