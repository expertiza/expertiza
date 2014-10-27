#TODO: rename to ChartDataPacket [OSS project, Fall 2014_Team2 comment: We retained the name as the file creates a chart object which can be rendered]
#TODO: find a fitting place for this file maybe in module [OSS project, Fall 2014_Team2 comment: Helper folder seems to be the right place 
                                                          # as this is a helper file which converts given data into a chart object]
class Chart
  @@chart_index = 0
  @@header = false
  attr :chart_id
  attr :width
  attr :data

  def initialize(type,data,option=nil,width = nil)
    @@chart_index = @@chart_index + 1
    chart_data = self.class.dataAdapter(type,data,option);
    unless width.nil?
      @width = width
    end
    @data = chart_data
    @chart_id = @@chart_index
  end

  def get_id_str()
    "chart_container_" + @chart_id.to_s
  end

  def self.include_header?()
    !@@header
  end

  def self.set_header()
    @@header = true
  end

  def self.dataAdapter(type,data,optionalConf)
    template = data_template[type];
    if (type == :pie) then
      template = set_pie_data(data,template)
    else
      template[:series] = data
    end
    if optionalConf.nil? then
      template = set_template_optional_params(template)
    else
      if optionalConf[:title].nil? then
        template[:title][:text] = ""
      else
        template[:title][:text] = optionalConf[:title]
      end
      template=validate_optional_conf(optionalConf,template)
    end
    template
  end

  def self.set_template_optional_params(template)
    template[:title][:text] = ""
    template.delete(:subtitle)
    template.delete(:yAxis)
    template.delete(:xAxis)
    template
  end

  def self.validate_optional_conf(optionalConf,template)
    if optionalConf[:subtitle].nil? then
      template.delete(:subtitle)
    else
      template[:subtitle]={}
      template[:subtitle][:text]=optionalConf[:subtitle]
    end

    if optionalConf[:y_axis].nil? then
      template.delete(:yAxis)
    else
      template[:yAxis][:title][:text]=optionalConf[:y_axis]
    end

    if optionalConf[:x_axis].nil? then
      template[:xAxis].delete(:title)
    else
      template[:xAxis][:title][:text] = optionalConf[:x_axis]
    end

    if optionalConf[:x_axis_categories].nil? then
      template[:xAxis].delete(:categories)
    else
      template[:xAxis][:categories]=optionalConf[:x_axis_categories]
    end
    template
  end

  def self.data_template()
    {
      :pie => get_pie_template,
      :bar => get_bar_template,
      :line => get_line_template,
      :scatter => get_scatter_template
    }
  end

  def self.get_generic_template() #Currently used for bar and line graphs
    {
        :title => {:text => "Review score for XXXX"},
        :subtitle => {:text => "subtitle here"},
        :xAxis => {
            :title =>{},
            :categories => [ 'Problem1', 'Problem2', 'Problem3', 'Problem4', 'Problem5', 'Problem6', 'Problem7', 'Problem8', 'Problem9', 'Problem10', 'Problem11','Problem12']
        },
        :yAxis => {
            :min => 0,
            :title => {
                :text => 'score'
            }
        },
        :tooltip => {
            :headerFormat => '<span style="font-size:10px">{point.key}</span><table>',
            :pointFormat => '<tr><td style="color:{series.color};padding:0">{series.name}: </td>' +'<td style="padding:0"><b>{point.y:.1f} mm</b></td></tr>',
            :footerFormat => '</table>',
            :shared => true,
            :useHTML => true
        },
        :plotOptions => {
            :column => {
                :pointPadding => 0.2,
                :borderWidth => 0
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
  end

  def self.get_pie_template()
    {
      :chart => {
        :plotBackgroundColor => nil,
        :plotBorderWidth => 1,
        :plotShadow => false
    },
        :title => {
        :text => 'Title'
    },
        :tooltip => {
        :pointFormat => '{series.name}: <b>{point.percentage:.1f}%</b>'
    },
        :plotOptions=> {
        :pie=> {
            :allowPointSelect => true,
            :cursor => 'pointer',
            :dataLabels=> {
                :enabled=> true,
                :format=> '<b>{point.name}</b>: {point.percentage:.1f} %',
                :style => {
                    :color=> 'black'
                }
            }
        }
    },
        :series => [{
                     :type => 'pie',
                     :name => 'Total share',
                     :data => [
                         ['Firefox',   45.0],
                         ['IE',       26.8],
                         ['Chrome',   12.8],
                         ['Safari',    8.5],
                         ['Opera',     6.2],
                         ['Others',   0.7]
                     ]
                 },
                  ]
    }
  end

  def self.get_bar_template()
    generic_template = get_generic_template  #Adding :chart object to the generic template
    generic_template[:chart] = {
        :type => 'column'
    }
    generic_template
  end

  def self.get_line_template()
    get_generic_template
  end

  def self.get_scatter_template
    {
        :chart => {
            :type => 'scatter',
            :zoomType => 'xy'
        },
        :title => {
            :text => 'Height Versus Weight of 507 Individuals by Gender'
        },
        :subtitle => {
            :text => 'Source: Heinz  2003'
        },
        :xAxis => {
            :title => {
                :enabled => true,
                :text => 'Height (cm)'
            },
            :startOnTick => true,
            :endOnTick => true,
            :showLastLabel => true
        },
        :yAxis => {
            :title => {
                :text => 'Weight (kg)'
            }
        },
        :legend => {
            :layout => 'vertical',
            :align => 'left',
            :verticalAlign => 'top',
            :x => 100,
            :y => 70,
            :floating => true,
            :backgroundColor => '#FFFFFF',
            :borderWidth => 1
        },
        :plotOptions => {
            :scatter => {
                :marker => {
                    :radius => 5,
                    :states => {
                        :hover => {
                            :enabled => true,
                            :lineColor => 'rgb(100,100,100)'
                        }
                    }
                },
                :states => {
                    :hover => {
                        :marker => {
                            :enabled => false
                        }
                    }
                },
                :tooltip => {
                    :headerFormat => '<b>{series.name}</b><br>',
                    :pointFormat => '{point.x} cm, {point.y} kg'
                }
            }
        },
        :series => [
            {
                :name => 'Female',
                :color => 'rgba(223, 83, 83, .5)',
                :data => [[161.2, 51.6], [167.5, 59.0], [159.5, 49.2], [157.0, 63.0], [155.8, 53.6],
                          [169.5, 67.3], [160.0, 75.5], [172.7, 68.2], [162.6, 61.4], [157.5, 76.8],
                          [176.5, 71.8], [164.4, 55.5], [160.7, 48.6], [174.0, 66.4], [163.8, 67.3]]

            }, {
                :name => 'Male',
                :color => 'rgba(119, 152, 191, .5)',
                :data => [[174.0, 65.6], [175.3, 71.8], [193.5, 80.7], [186.5, 72.6], [187.2, 78.8],
                          [170.2, 62.3], [177.8, 82.7], [179.1, 79.1], [190.5, 98.2], [177.8, 84.1],
                          [180.3, 83.2], [180.3, 83.2]]
            }]
    }
  end

  def self.set_pie_data(data, template)
    template[:series][0][:data] = Array.new
    data.each do |obj|
      temp = Array.new
      temp << obj[:name]
      if(!obj[:data].nil?)
        temp << obj[:data][0]
      else
        temp << 0
      end
      template[:series][0][:data] << temp
    end
    template[:series][0][:type] = 'pie'
    template
  end

  def self.test_data()
    {
      :course_list => [["course 1",1],["course 2",2],["course 3",3]],
      :assignment_list => [["assignment 1",1],["assignment 2",2],["assignment",3]],
      :team_list => [["team 1",1],["team 2",2],["team 3",3]],
      :chart_obj => Chart.data_template()[:bar]
    }
  end
end
