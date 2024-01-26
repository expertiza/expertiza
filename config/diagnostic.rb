module MyApp
  # Logger to sit between test and server end. When using Selenium these are not reported in tests, error pages are just another web page
  class DiagnosticMiddleware
    FILENAME = 'log/diagnostic.txt'.freeze

    def initialize(app)
      @app = app
    end

    def call(env)
      @app.call(env)
    rescue StandardError => e
      trace = e.backtrace.select { |l| l.start_with?(Rails.root.to_s) }.join("\n    ")
      msg = "#{e.class}\n#{e.message}\n#{trace}\n"
      File.open(FILENAME, 'a') { |f| f.write msg }
      raise e
    end
  end
end
