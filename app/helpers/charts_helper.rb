module ChartsHelper

  # labels array of labels
  # values array of values
  def self.get_pie_chart_url(labels, values)
      if labels.length != values.length
        return  ""  
      end
      
      address = "http://chart.apis.google.com/chart?cht=p3&chs=300x125"
      max = 100.0
      for value in values
        max = value if value > max
      end
      
      max = max/100.0
      
      value_string = "&chd=t:"
      label_string = "&chl="
      color_string = "&chco="
      
      i = 0
      for value in values
        unless value == 0
          value_string += (value/max).to_i.to_s + ","
          label_string += labels[i].to_s + "|" 
          
          ratio = (i+0.5)/(values.length/2.0)
          
          if ratio < 1.0
            color = sprintf("%02x", 256*ratio)
            color_string += "ff" + color + color + ","
          elsif ratio == 1.0
            color_string += "ffffff,"
          else
            color = sprintf("%02x", 256*(2.0-ratio))
            color_string += color + "ff" + color + ","
          end
          
        end  
        i += 1
      end 
      
      value_string = value_string[0..-2]   # remove last comma
      label_string = label_string[0..-2]   # remove last "|"      
      color_string = color_string[0..-2]   # remove last comma
      
      address += value_string + label_string + color_string
  end
end