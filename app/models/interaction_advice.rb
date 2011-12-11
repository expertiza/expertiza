class InteractionAdvice < ActiveRecord::Base
  belongs_to  :assignment, :class_name => 'Assignment', :foreign_key => 'assignment_id'


  def self.find_advices(assignment_id)
    advice_array  = InteractionAdvice.find_all_by_assignment_id(assignment_id)
    i=advice_array.length
    (i..20).each do|index|
      advice_array[index] = InteractionAdvice.new
    end
    return advice_array

  end

  def self.find_num_advices(assignment_id)
    return InteractionAdvice.find_all_by_assignment_id(assignment_id).length
  end

  def self.update_advice(advices,assignment_id)
    advice_map = Hash.new
    advices.each do|advice|
      if(advice[1][:advice].blank? or advice[1][:score].blank?)
         return 'You have left something blank'
      end
      if !(/^[\d]+/ === advice[1][:score])
         return 'Score is not a number'
      end
      if(advice_map.has_key?(advice[1][:score]))
        return 'The score' +advice[1][:score] + 'has dual entries'
      end

      advice_map[advice[1][:score]] = advice[1][:advice]

    end



    existing_advices = InteractionAdvice.find_all_by_assignment_id(assignment_id)
    if !existing_advices.nil?
      existing_advices.each do |advice|
        advice.destroy
      end
    end

    advice_map.each do|score,advice|
        new_advice = InteractionAdvice.new
        new_advice.assignment_id=assignment_id
        new_advice.score = score
        new_advice.advice= advice
        new_advice.save
    end




    return nil

  end



end

