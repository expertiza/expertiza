module ChartHelper
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

  # Separate function to initializee optional parameters field. Supports Separation of responsibility.

    def self.set_template_optional_params(template)
      template[:title][:text] = ""
      template.delete(:subtitle)
      template.delete(:yAxis)
      template.delete(:xAxis)
      template
    end

  #Separate function to validate optional parametrs field which supports separation of responsibility and reduces code duplication.

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
        :pie => YAML.load_file('config/charts/pie.yml'),
        :bar => YAML.load_file('config/charts/bar.yml'),
        :line => YAML.load_file('config/charts/line.yml'),
        :scatter => YAML.load_file('config/charts/scatter.yml')
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
        :chart_obj => ChartHelper.data_template()[:bar]
      }
    end
  end
end
