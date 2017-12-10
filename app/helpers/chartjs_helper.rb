module ChartjsHelper
  require 'json'
  require 'bigdecimal'

  def chart(type, data, options)
        @chart_id ||= -1
        element_id = options.delete(:id)     || "chart-#{@chart_id += 1}"
        css_class  = options.delete(:class)  || 'chart'
        width      = options.delete(:width)  || '400'
        height     = options.delete(:height) || '400'

        canvas = content_tag :canvas, '', id: element_id, class: css_class, width: width, height: height

        script = javascript_tag do
          <<-END.squish.html_safe
        (function() {
          var initChart = function() {
            var ctx = document.getElementById(#{element_id.to_json});

            var chart = new Chart(ctx, {
              type:    "#{camel_case type}",
              data:    #{to_javascript_string data},
              options: #{to_javascript_string options}
            });
          };

          if (typeof Chart !== "undefined" && Chart !== null) {
            initChart();
          }
          else {
            /* W3C standard */
            if (window.addEventListener) {
              window.addEventListener("load", initChart, false);
            }
            /* IE */
            else if (window.attachEvent) {
              window.attachEvent("onload", initChart);
            }
          }
        })();
          END
        end

        canvas + script
  end

  # polar_area -> polarArea
  def camel_case(string)
    string.gsub(/_([a-z])/) { $1.upcase }
  end

  def to_javascript_string(element)
    case element
      when Hash
        hash_elements = []
        element.each do |key, value|
          hash_elements << camel_case(key.to_s).to_json + ':' + to_javascript_string(value)
        end
        '{' + hash_elements.join(',') + '}'
      when Array
        array_elements = []
        element.each do |value|
          array_elements << to_javascript_string(value)
        end
        '[' + array_elements.join(',') + ']'
      when String
        if element.match(/^\s*function.*}\s*$/m)
          # Raw-copy function definitions to the output without surrounding quotes.
          element
        else
          element.to_json
        end
      when BigDecimal
        element.to_s
      else
        element.to_json
    end
  end

  class Engine < Rails::Engine
    initializer 'chartjs.chart_helpers' do
      if ::Chartjs.no_conflict
        ActionView::Base.send :include, Chartjs::ChartHelpers::Explicit
      else
        ActionView::Base.send :include, Chartjs::ChartHelpers::Implicit
      end
    end
  end

end
