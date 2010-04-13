class Service

  def initialize(controller = nil)
    @controller = controller
    @is_running = true
    
    if @controller.nil?
      trap("TERM") { stop }
    end
  end
  
  def running?
    return @is_running if @controller.nil?
    @controller.running?
  end
  
  def daydream(seconds)
    start = Time.now.to_i
    while running? && (Time.now.to_i - start) < seconds
      sleep 1
    end
  end
  
  def logger
    RAILS_DEFAULT_LOGGER
  end
  
  def stop
    @is_running = false
  end
  
  # Defines a start method that executes the given block and sleeps
  # sleep_seconds. Repeats this for ever. Takes care of exceptions.
  def self.loop_with_sleep(sleep_seconds, &block)
    raise 'no block given for loop_with_sleep' if not block_given?
    define_method('start') do
      while running?
        begin
          instance_eval(&block)
        rescue Exception => err
          logger.error "Daemon failure: #{err} #{err.backtrace}"
        end
        daydream sleep_seconds
      end
    end
  end

end
