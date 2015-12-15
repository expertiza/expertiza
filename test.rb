class Array

  def each_to_power(pow)
    self.each {|x| map x**pow}
  end

end

n = 4
sum_of_cubes_from_1_to_n = 0

(1..n).to_a().each_to_power(3) { |x| sum_of_cubes_from_1_to_n += x }

puts sum_of_cubes_from_1_to_n
