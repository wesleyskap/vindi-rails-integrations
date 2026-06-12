# frozen_string_literal: true

module Vindi
  module Webhooks
    class BaseHandler
      attr_reader :event_payload

      def initialize(event_payload)
        @event_payload = event_payload
      end

      def call
        raise NotImplementedError, "#{self.class} must implement #call"
      end
    end
  end
end
