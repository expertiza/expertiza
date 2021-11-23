class AddHeatgridMetricToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :heatgrid_metric, :string, default: 'countofcomments'
  end
end
