class AddExtraParamToDelayedJobs < ActiveRecord::Migration
  def change
    add_column :delayed_jobs, :extra_param, :string
  end
end
