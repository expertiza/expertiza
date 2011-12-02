class TeamConflict
  attr_reader :first_person, :second_person, :conflict_type, :threshold

  def initialize(first_person, second_person, conflict_type, threshold)
    @first_person = first_person

    if first_person != second_person
      @second_person = second_person
    else
      @second_person = nil
    end

    @conflict_type = conflict_type
    @threshold = threshold
  end
end