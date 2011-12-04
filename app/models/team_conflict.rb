class TeamConflict
  attr_reader :first_person, :second_person, :type, :threshold

  def initialize(first_person, second_person, type, threshold)
    @first_person = first_person
    @second_person = second_person
    @type = type
    @threshold = threshold
  end

end