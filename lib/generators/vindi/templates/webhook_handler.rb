# frozen_string_literal: true

module Vindi
  module Webhooks
    class <%= class_name %>Handler < BaseHandler
      def call
        # Implement dynamic business action logic for <%= file_name %> event here.
        # Access the event details via `event_payload`.
        # Example:
        # Rails.logger.info "Processing <%= file_name %> with payload: #{event_payload.inspect}"
      end
    end
  end
end
