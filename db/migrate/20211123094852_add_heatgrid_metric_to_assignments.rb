#Add a column of heatgrid metric in assignments table
class AddHeatgridMetricToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :heatgrid_metric, :string, default: 'word count > 10'
  end
end
