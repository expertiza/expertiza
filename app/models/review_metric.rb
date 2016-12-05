class ReviewMetric < ActiveRecord::Base
    belongs_to :response_maps, class_name: 'ResponseMap', foreign_key: 'response_id'

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

    def self.calculate_metrics(assignment_id, reviewer_id)
        answers = Answer.joins("join responses on responses.id = answers.response_id")
                       .joins("join response_maps on responses.map_id = response_maps.id")
                       .where("response_maps.reviewed_object_id = ? and response_maps.reviewer_id = ?", assignment_id, reviewer_id)
                       .select("answers.comments, answers.response_id").order("answers.response_id")
        suggestive_words = Set.new(["should", "recommend", "suggest", "advise", "try"])
        offensive_words = Set.new(["lame", "stupid", "dumb", "idiot"])
        problem_words = Set.new(["wrong", "error", "problem", "issue"])
        current_response_id = nil
        dict = Hash.new()
        metrics = []
        answers.each do |ans|
            # puts ans.comments
            comment = ans.comments
            if current_response_id.nil? or current_response_id != ans.response_id
                current_response_id = ans.response_id
                dict[current_response_id] = comment
            else
                dict[current_response_id] = dict[current_response_id] + comment
            end
        end
        denom = dict.length
        dict.each_pair do |key, value|
        word_counter = 0   
	 offensive_metric = 0
            suggestive_metric = 0
            problem_metric = 0
            is_offensive_term = false
            is_suggestion = false
            is_problem = false
            value.scan(/[\w']+/).each do |word|
                word_counter = word_counter + 1
		if offensive_words.include? word
                    is_offensive_term = true
                end
                if suggestive_words.include? word
                    is_suggestion = true
                end
                if problem_words.include? word
                    is_problem = true
                end
            end
            if is_offensive_term
                offensive_metric += 1
            end
            if is_problem
                problem_metric += 1
            end
            if is_suggestion
                suggestive_metric += 1
            end
            if ReviewMetric.exists?(response_id: key)
                obj = ReviewMetric.find_by(response_id: key)
            else
                obj = ReviewMetric.new()
                obj.response_id = key
            end
            # puts "Suggestion: #{is_suggestion}, Offensive: #{is_offensive_term}, Problem: #{is_problem}"
        	obj.update_attribute(:volume, word_counter)
	    obj.update_attribute(:suggestion, is_suggestion)
            obj.update_attribute(:offensive_term, is_offensive_term)
            obj.update_attribute(:problem, is_problem)
            obj.save!
            # puts "Object-Suggestion: #{obj.suggestion}, Object-Offensive: #{obj.offensive_term}, Object-Problem: #{obj.problem}"
            offensive_percent = ((offensive_metric.fdiv(denom))*100).round(2)
            problem_percent = ((problem_metric.fdiv(denom))*100).round(2)
            suggestion_percent = ((suggestive_metric.fdiv(denom))*100).round(2)
            metrics << [key, word_counter, suggestion_percent, problem_percent, offensive_percent]
        end
        metrics
    end
end
