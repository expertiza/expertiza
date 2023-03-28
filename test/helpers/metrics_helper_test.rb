require 'test_helper'

class MetricsHelperTest < ActionView::TestCase
  include MetricsHelper

  test "display_github_metrics should return a chart object" do
    parsed_data = {
      "author1" => { "2018-09-01" => 5, "2018-09-02" => 3 },
      "author2" => { "2018-09-01" => 2, "2018-09-02" => 1 }
    }
    authors = [["author1", "Author 1"], ["author2", "Author 2"]]
    dates = ["2018-09-01", "2018-09-02"]

    chart = display_github_metrics(parsed_data, authors, dates)

    assert_instance_of GoogleChart::HorizontalBarChart, chart
  end

  test "display_totals_piechart should return a string URL" do
    parsed_data = {
      "author1" => { "2018-09-01" => 5, "2018-09-02" => 3 },
      "author2" => { "2018-09-01" => 2, "2018-09-02" => 1 }
    }
    authors = [["author1", "Author 1"], ["author2", "Author 2"]]
    dates = ["2018-09-01", "2018-09-02"]

    url = display_totals_piechart(parsed_data, authors, dates)

    assert_instance_of String, url
    assert_match %r{^https?://}, url
  end

  test "chart_options should return a hash" do
    options = chart_options

    assert_instance_of Hash, options
    assert_includes options.keys, :responsive
    assert_includes options.keys, :maintainAspectRatio
    assert_includes options.keys, :width
    assert_includes options.keys, :height
    assert_includes options.keys, :scales
  end

  test "graph_scales should return a hash" do
    scales = graph_scales

    assert_instance_of Hash, scales
    assert_includes scales.keys, :yAxes
    assert_includes scales.keys, :xAxes
    assert_instance_of Array, scales[:yAxes]
    assert_instance_of Array, scales[:xAxes]
  end
end
