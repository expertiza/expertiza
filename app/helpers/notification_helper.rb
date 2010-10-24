module NotificationHelper
  require 'date'

  def string_to_class(class_name)
    class_found = nil

    begin
      # convert the string to the class
      class_found = Object.const_get(class_name)
    rescue
      return nil
    end

    if(class_found == nil)
      return nil
    end

    # verify that the object found is actually a class
    class_found_class = class_found.class()
    if(class_found_class == nil)
      return nil
    end

    if(class_found_class.to_s != "Class")
      return nil
    end

    return class_found;
  end

  def find_entries_meeting_conditions(table_name, join_tables_string, meta_condition_list, selection_criteria_strings)
    compiled_table = string_to_class(table_name)
    if(compiled_table == nil)
      return nil
    end

    join_string = "";
    if(join_tables_string != nil)
      join_pairs = join_tables_string.split(',')
      for join_pair in join_pairs
        join_tables = join_pair.split('=')
        secondary_table = join_tables[0].split('.')[0]
        join_string += " INNER JOIN #{secondary_table} ON #{join_pair}";
      end
    end

    test_conditions = []

    first_condition = true
    cumulative_search_string = ""
    for meta_condition in meta_condition_list
      if(!first_condition)
        cumulative_search_string += " AND "
      end

      cumulative_search_string += "#{meta_condition.data_name} #{meta_condition.condition} ? "
      test_conditions << eval(meta_condition.comparison_value)

      first_condition = false
    end

    vars_wanted = []

    # Alias all of the output variables to a avoid conflicts
    # "assignments.name, users.name"
    # "assignments.name AS assignment_name, users.name AS user_name"
    first_selection = true
    selection_string = "";
    for selection_criteria_string in selection_criteria_strings
      rename = selection_criteria_string.gsub('.', '_')

      if(!first_selection)
        selection_string += ", "
      end

      selection_string += "#{selection_criteria_string} AS #{rename}"

      vars_wanted << rename

      first_selection = false
    end

    test_conditions.insert(0, cumulative_search_string)

    # execute the joins, test the conditions, and return the desired data
    results = compiled_table.find(:all, :joins => join_string, :conditions => test_conditions, :select => selection_string)

    # Compile an array of hashes with all the returned data
    compiled_results = []
    for result in results
      # Make a hash containing the desired variables
      var_hash = Hash.new
      for var in vars_wanted
        var_hash[var] = result.instance_eval(var)
      end

      compiled_results << var_hash
    end

    return compiled_results
  end

  def fill_placeholders(base_message, data_hash)
    populated_message = base_message
    data_hash.each_pair {|key, value|
      place_holder_identifier = "<#{key}>"
      populated_message = populated_message.gsub(place_holder_identifier, value) }
    return populated_message
  end

end
