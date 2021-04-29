class MetricSource < ActiveRecord::Base
  #E2111 This record is used as a lookup management table for metrics. The design intent, developed using notes from
  # 2017 expertiza team meeting minutes, is to control Metrics by source, so that Metrics can be expanded to include
  # future types of Metric like TravisCI details, feedback from Codeclimate, and similar, without needing to have
  # separate types of Metric to handle each of these different metric datapoints.

end
