# Generic channel handler that enqueues jobs to rabbit.
# Subclasses must define job_class
module GenericChannel
  extend ActiveSupport::Concern

  included do
    after_create :create_worker_queue
    after_update :enable_worker_queue, :if => lambda { (enabled_changed? && enabled) || (paused_changed? && !paused) }
    after_update :disable_worker_queue, :if => lambda { (enabled_changed? && !enabled) || (paused_changed? && paused) }
    before_destroy :destroy_worker_queue
  end

  module InstanceMethods
    def handle(msg)
      Queues.publish_ao msg, create_job(msg)
    end

    def create_worker_queue
      Queues.bind_ao self
      WorkerQueue.create! :queue_name => Queues.ao_queue_name_for(self), :working_group => 'fast', :ack => true, :durable => true
    end

    def worker_queue
      WorkerQueue.for_channel self
    end

    def enable_worker_queue
      worker_queue.try :enable!
    end

    def disable_worker_queue
      worker_queue.try :disable!
    end

    def destroy_worker_queue
      worker_queue.try :destroy
    end
  end
end
