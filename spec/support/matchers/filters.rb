RSpec::Matchers.define :execute_before_filter do |filter_name, options|
  match do |controller|
    controller.stubs(filter_name).raises(StandardError.new("Filter executed: #{filter_name}"))

    if options[:stub_filters]
      options[:stub_filters].each do |filter|
        controller.stubs(filter).returns(true)
      end
    end

    result = begin
      send(options[:via], options[:on], options[:with])
      false
    rescue StandardError => e
      e.message == "Filter executed: #{filter_name}"
    rescue
      false
    end
    result
  end

  failure_message do |actual|
    filter = expected[0]
    options = expected[1]
    action = options[:on]
    with = options[:via]
    params = options[:with]
    message = "expected #{actual.class} to execute filter #{filter}"
    message << " before action #{action}"
    message << " [requested via #{with} with params '#{params}']."
  end

  failure_message_when_negated do |actual|
    filter = expected[0]
    options = expected[1]
    action = options[:on]
    with = options[:via]
    params = options[:with]
    message = "expected #{actual.class} not to execute filter #{filter}"
    message << " before action #{action}"
    message << " [requested via #{with} with params '#{params}']"
  end
end

