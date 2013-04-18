require 'json'
class ChartHelper

  @@chart_trace = 0
  @chart_id

  def initialize()
    @@chart_trace = @@chart_trace + 1
    @chart_id = "chart_container_" + @@chart_trace.to_s
  end

  def get_id()
    @chart_id
  end

  def self.testData()
    return {
        :bar => {
            #:type => 'column',
            :title => {:text => "Review score for XXXX"},
            :subtitle => {:text => "subtitle hewe"},
            :xAxis => {
                :categories => [ 'Problem1', 'Problem2', 'Problem3', 'Problem4', 'Problem5', 'Problem6', 'Problem7', 'Problem8', 'Problem9', 'Problem10', 'Problem11','Problem12']
            },
            :yAxis => {
                :min => 0,
                :title => {
                    :text => 'score'
                }
            },
            :series => [
                {
                    :name => 'review 1',
                    :data => [9.9, 7.5, 6.4, 9.2, 4.0, 6.0, 5.6, 8.5, 6.4, 4.1, 5.6, 4.4]
                }, {
                    :name => 'review 2',
                    :data =>  [3.6, 8.8, 8.5, 3.4, 6.0, 4.5, 5.0, 4.3, 9.2, 8.5, 6.6, 9.3]
                }, {
                    :name => 'review 3',
                    :data => [8.9, 8.8, 9.3, 4.4, 7.0, 8.3, 9.0, 9.6, 5.4, 6.2, 9.3, 5.2]
                }
            ]
        }
    }
  end
end