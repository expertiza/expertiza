require 'yaml'

# ViewTranslationSubstitutor is a model responsible for substituting translation keys in view files
# with their corresponding values from a given locale hash and generating statistics about the
# translation process. This allows for standardization across world languages.
class ViewTranslationSubstitutor
  # Regular expression pattern to ignore certain text during translation.
  BLACKLIST = "([a-zA-Z0-9\\._]+|[\"\\'])?".freeze

  # Substitute method processes the locale hash and generates translation statistics to a YAML file.
  def substitute(locale)
    stats = {} # Hash to store translation statistics.
    # Iterate over each directory and its associated view translations.
    locale.each { |dir_name, view_hash| stats[dir_name] = process_files_in_directory(dir_name, view_hash) }
    # Write translation statistics to a YAML file.
    File.open("translation_stats#{Time.now}.yml", 'w') { |file| file.write(stats.to_yaml) }
  end

  private

  # Process directory method iterates through each view hash within a directory and returns the directory statistics.
  def process_files_in_directory(dir_name, view_hash)
    # Hash to store translation statistics for each directory.
    dir_stats = {}
    # Process translations for each view within the directory.
    view_hash.each { |view_name, translations| dir_stats[view_name] = process_view(dir_name, view_name, translations) }
    # Return directory statistics.
    dir_stats
  end

  # Process view method handles the translation process for a specific view and if no such file exists then returns error.
  def process_view(directory_name, view_name, translations)
    # Path to the primary view file.
    path = "./#{directory_name}/#{view_name}.html.erb"

    # If the primary view file doesn't exist...
    unless File.exist?(path)
      # Check for an alternate view file.
      path = "./#{directory_name}/_#{view_name}.html.erb"
      # Return an error message if no alternate file is found.
      return '<file not found>' unless File.exist?(path)
    end

    # Hash to store translation statistics for the view.
    view_stats = {}
    # Read the contents of the view file.
    contents = File.open(path, 'w') { |file| file.read } || ''
    # Process translations for each key-value pair.
    translations.each { |key, val| view_stats[key], contents = process_translation(contents, key, val) }
    # Write the updated contents back to the view file.
    File.open(path, 'w') { |f| f.write contents }
    # Return view statistics.
    view_stats
  end

  # Process translation method performs the actual translation within the view contents for standardization.
  def process_translation(contents, key, val)
    # Array to store text replacements.
    replacements = []
    # Array to store skipped text.
    skips = []
    # Index to resume searching for matches within the contents.
    resume_index = 0

    while resume_index < contents.length
      # Match translation text within the contents.
      match_data = contents[resume_index, contents.length].match(/#{BLACKLIST}(\s+)?(#{Regexp.escape(val)})(\s+)?#{BLACKLIST}/)
      # Exit the loop if no match is found.
      break if match_data.nil?
      # Beginning index of the matched text.
      match_begin = resume_index + match_data.begin(0)
      # Ending index of the matched text.
      match_end = resume_index + match_data.end(0)
      # Extract the matched text.
      matched_text = match_data[0]
      # Text preceding the translation text.
      black_start = match_data[1]
      # Leading whitespace of the translation text.
      white_start = match_data[2]
      # Trailing whitespace of the translation text.
      white_end = match_data[4]
      # Text following the translation text.
      black_end = match_data[5]

      # If the translation text is enclosed in quotes or preceded/followed by a specific pattern...
      if black_start == black_end && (black_start.nil? || ["\"", "'"].include?(black_start))
        # Construct the translation replacement.
        t_call = black_start.nil? ? "#{key}" : "#{key}"
        # Construct the replacement string.
        replacement = "#{white_start}#{t_call}#{white_end}"
        # Store the matched text for replacement.
        replacements += [contents[match_begin, matched_text.length]]
        # Replace the matched text with the translation.
        contents[match_begin, matched_text.length] = replacement
        # Update the resume index.
        resume_index = match_begin + replacement.length
      else
        # Move the resume index to the end of the matched text.
        resume_index = match_end
        # Store the skipped text.
        skips += [matched_text]
      end
    end

    # Hash to store translation statistics.
    translation_stats = {}
    # Store replacement statistics if replacements were made.
    translation_stats['replacements'] = replacements unless replacements.empty?
    # Store skip statistics if text was skipped.
    translation_stats['skips'] = skips unless skips.empty?
    # Set a default value if no statistics were recorded.
    translation_stats = '<unmatched>' if translation_stats == {}

    # Return translation statistics and updated contents.
    [translation_stats, contents]
  end
end
