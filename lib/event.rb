# frozen_string_literal: true

class Event
  NotCallable = StandardError.new

  def initialize
    @handlers = []
  end

  def subscribe(handler)
    raise NotCallable unless handler.respond_to?(:call)

    self.handlers << handler
  end

  def unsubscribe(handler)
    self.handlers.reject! { |h| h.object_id == handler.object_id }
  end

  def broadcast(*arguments)
    handlers.each do |handler|
      handler.call(*arguments)
    end
  end

  private

  attr_accessor :handlers
end
