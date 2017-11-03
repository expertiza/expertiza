module DelayedTaskHelper
  def due_time(delayed_time)
    due_at = DateTime.now.in_time_zone + delayed_time
    Time.zone.parse(due_at.to_s(:db))
  end

  def current_time
    curr_time = DateTime.now.in_time_zone.to_s(:db)
    Time.zone.parse(curr_time)
  end

  def time_to_run(delayed_time)
    ((due_time(delayed_time) - current_time).to_i / 60) * 60
  end

  def enqueue_delayed_job(stage, delayed_time)
    id = 2
    Delayed::Job.delete_all
    expect(Delayed::Job.count).to eq(0)
    Delayed::Job.enqueue(payload_object: DelayedMailer.new(id, stage, DateTime.now.in_time_zone + delayed_time), priority: 1, run_at: time_to_run(delayed_time))
  end
end
