#these 4 helpers consist of the list of plot options that are available for the graph type
module LineGraphHelper
  #development note
  # 1)method for generate the data packet has already been - completed: helpers/chart_helper.rb
  # 2)javascript for rendering the chart - partially completed
  #   currently value x axis can not be independently set
  # 3)data mining method for gathering data - partially completed
  #   there's always more to add
end

module BarChartHelper

end

module PieChartHelper
  #only for single object compaireson meaning
  # 1)method for generate the data packet has already been - completed: helpers/chart_helper.rb
  # 2)javascript for rendering the chart - completed

  # good for showing grade distributions
  # methods needed to convert the data gathered to useful way of displaying
end

module ScatterPlotHelper
  # 1)method for generate the data packet has already been - completed: helpers/chart_helper.rb
  # 2)javascript for rendering the chart - completed


end

module AnalyticHelper
  include ChartHelper
  #====== generic method to generate chart data (chart_type decides which chart to render) ================#
  def get_chart_data(chart_type, object_type, object_id_list, data_type_list)
    data_point = Array.new
    object_model = Object.const_get(object_type.capitalize)
    object_id_list.each do |object_id|
      object = object_model.find(object_id)
      object_data = Hash.new
      object_data[:name] = object.name
      object_data[:data] = gather_data(object, data_type_list)
      data_point << object_data
    end
    # Formatting the optional parameters field ( pie charts do not support optional parameters )
    if(chart_type !="pie")
      option = Hash.new
      option[:x_axis_categories] =data_type_list
    else
      option = nil
    end
    Chart.new(chart_type.to_sym, data_point, option).data
  end

  def gather_data(object, data_type_array)
    data_array = Array.new
    data_type_array.each do |data_method|
      data_array << object.send(data_method)
    end
    data_array
  end

  #======== sorting ============#
  def sort_by_name(array_of_arrays)
    array_of_arrays.sort {|x,y| x[0] <=> y[0]}
  end

  #======= helper data formatting =====#
  #TODO: implementing normalize for bar chart
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
