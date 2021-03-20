require 'test_helper'

class DueDateTest < ActiveSupport::TestCase
  describe reminder do
      def queue_adapter_for_test
        ActiveJob::QueueAdapters::DelayedJobAdapter.new
      end
      
      it 'enqueues remainder email in delayed job queue' do
        expect {
          delay.reminder()
        }.to change(Delayed::Job.count).by(1)
      end
    end


    describe start_reminder do
      def queue_adapter_for_test
        ActiveJob::QueueAdapters::DelayedJobAdapter.new
      end
      
      it 'enqueues remainder job in delayed job queue' do
        expect {
          delay.start_reminder()
        }.to change(Delayed::Job.count).by(1)
      end
    end
end