module AnalyticHelper
  def normalize(array)
    normalized_array = Array.new
    max = array.max
    array.each do |element|
      normalized_array << element.to_f/max
    end
    normalized_array
  end

  def distribution(array, num_intervals, x_min = array.min)
    distribution = Array.new
    interval_size = ((array.max - x_min).to_f/num_intervals).ceil
    intervals = (1..num_intervals).to_a.collect { |val| val*interval_size }
    intervals.each do |interval_max|
      distribution << array.select { |a| a < interval_max }.count
      array.reject! { |a| a < interval_max }

    end
    distribution
  end

  def distribution_categories(array, num_intervals, x_min = array.min)
    categories = Array.new
    interval_size = ((array.max - x_min).to_f/num_intervals).ceil
    intervals = (1..num_intervals).to_a.collect { |val| val*interval_size }
    interval_min = 0
    intervals.each do |interval_max|
      categories << (interval_min..interval_max).to_s
      interval_min = interval_max
    end
    categories
  end
end