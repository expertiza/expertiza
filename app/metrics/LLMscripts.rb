require 'rubocop'
require 'flog'
require 'csv'

def analyze_class(file)
  method_count = 0
  lines_of_code = 0
  flogger = Flog.new
  
  File.readlines(file).each do |line|
    lines_of_code += 1
    method_count += 1 if line.strip.start_with?('def ')
  end

  # Analyze with Flog for cyclomatic complexity
  flogger.flog(file)
  cyclomatic_complexity = flogger.total_score
  
  # Use RuboCop to check for code offenses
  RuboCop::CLI.new.run([file])

  {
    methods: method_count,
    loc: lines_of_code,
    complexity: cyclomatic_complexity
  }
end

# Open a CSV file to write the output
CSV.open("analysis_output.csv", "wb") do |csv|
  # Add CSV headers
  csv << ["Class", "Methods", "LOC", "Cyclomatic Complexity"]

  # Analyze all .rb files in Expertiza directory
  Dir.glob('C:/Users/David Mond/expertiza/**/*.rb') do |file|
    next unless File.file?(file)
    result = analyze_class(file)
    
    # Write output to the CSV
    csv << [file, result[:methods], result[:loc], result[:complexity]]
  end
end