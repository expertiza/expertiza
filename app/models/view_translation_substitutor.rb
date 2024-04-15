require 'yaml'

# ViewTranslationSubstitutor is a model responsible for substituting translation keys in view files
# with their corresponding values from a given locale hash and generating statistics about the
# translation process. This allows for standardization accross world languages.
class ViewTranslationSubstitutor
  BLACKLIST = "([a-zA-Z0-9\\._]+|[\"\\'])?".freeze # Regular expression pattern to ignore certain text during translation.

  # Substitute method processes the locale hash and generates translation statistics.
  def substitute(locale)
    stats = {} # Hash to store translation statistics.
    locale.each { |dir_name, view_hash| stats[dir_name] = process_directory(dir_name, view_hash) } # Iterate over each directory and its associated view translations.
    File.open("translation_stats#{Time.now}.yml", 'w') { |file| file.write(stats.to_yaml) } # Write translation statistics to a YAML file.
  end

  private

  # Process directory method iterates through each view hash within a directory.
  def process_directory(dir_name, view_hash)
    dir_stats = {} # Hash to store translation statistics for each directory.
    view_hash.each { |view_name, translations| dir_stats[view_name] = process_view(dir_name, view_name, translations) } # Process translations for each view within the directory.
    dir_stats # Return directory statistics.
  end

  # Process view method handles the translation process for a specific view.
  def process_view(directory_name, view_name, translations)
    path = "./#{directory_name}/#{view_name}.html.erb" # Path to the primary view file.

    unless File.exist?(path) # If the primary view file doesn't exist...
      path = "./#{directory_name}/_#{view_name}.html.erb" # Check for an alternate view file.
      return '<file not found>' unless File.exist?(path) # Return an error message if no alternate file is found.
    end

    view_stats = {} # Hash to store translation statistics for the view.

    contents = File.open(path, 'w') { |file| file.read } || '' # Read the contents of the view file.

    translations.each { |key, val| view_stats[key], contents = process_translation(contents, key, val) } # Process translations for each key-value pair.
    File.open(path, 'w') { |f| f.write contents } # Write the updated contents back to the view file.

    view_stats # Return view statistics.
  end

  # Process translation method performs the actual translation within the view contents.
  def process_translation(contents, key, val)
    replacements = [] # Array to store text replacements.
    skips = [] # Array to store skipped text.
    resume_index = 0 # Index to resume searching for matches within the contents.

    while resume_index < contents.length
      match_data = contents[resume_index, contents.length].match(/#{BLACKLIST}(\s+)?(#{Regexp.escape(val)})(\s+)?#{BLACKLIST}/) # Match translation text within the contents.
      break if match_data.nil? # Exit the loop if no match is found.

      match_begin = resume_index + match_data.begin(0) # Beginning index of the matched text.
      match_end = resume_index + match_data.end(0) # Ending index of the matched text.
      matched_text = match_data[0] # Extract the matched text.
      black_start = match_data[1] # Text preceding the translation text.
      white_start = match_data[2] # Leading whitespace of the translation text.
      white_end = match_data[4] # Trailing whitespace of the translation text.
      black_end = match_data[5] # Text following the translation text.

      if black_start == black_end && (black_start.nil? || %W[\" '].include?(black_start)) # If the translation text is enclosed in quotes or preceded/followed by a specific pattern...
        t_call = black_start.nil? ? "#{key}" : "#{key}" # Construct the translation replacement.
        replacement = "#{white_start}#{t_call}#{white_end}" # Construct the replacement string.
        replacements += [contents[match_begin, matched_text.length]] # Store the matched text for replacement.
        contents[match_begin, matched_text.length] = replacement # Replace the matched text with the translation.
        resume_index = match_begin + replacement.length # Update the resume index.
      else
        resume_index = match_end # Move the resume index to the end of the matched text.
        skips += [matched_text] # Store the skipped text.
      end
    end

    translation_stats = {} # Hash to store translation statistics.
    translation_stats['replacements'] = replacements unless replacements.empty? # Store replacement statistics if replacements were made.
    translation_stats['skips'] = skips unless skips.empty? # Store skip statistics if text was skipped.
    translation_stats = '<unmatched>' if translation_stats == {} # Set a default value if no statistics were recorded.

    [translation_stats, contents] # Return translation statistics and updated contents.
  end
end
