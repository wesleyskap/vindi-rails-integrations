# frozen_string_literal: true

module Vindi
  # =========================================================================
  # VINDI WEBHOOK PAYLOAD STRUCTURE EXAMPLE:
  # {
  #   event: {
  #     id: 123456,                      # Unique ID for the webhook event (useful for idempotency)
  #     type: "bill_paid",               # Type of event (e.g. subscription_created, bill_paid, charge_rejected)
  #     created_at: "2026-06-10T15:00:00.000-03:00",
  #     data: {                          # Object data (context depends on the event type)
  #       bill: {
  #         id: 555,
  #         amount: "100.00",
  #         status: "paid",
  #         customer: { id: 123, email: "john@example.com", code: "app_user_id" },
  #         charges: [...]
  #       }
  #     }
  #   }
  # }
  # =========================================================================
  class WebhookJob < ActiveJob::Base
    queue_as :default

    def perform(payload)
      event_id = payload.dig(:event, :id)
      event_type = payload.dig(:event, :type)

      # BEST PRACTICE 1: Idempotency Check
      # Check if this event_id has already been processed to avoid duplicate actions.
      return if already_processed?(event_id)

      process_event(event_type, payload.dig(:event, :data))
      
      # BEST PRACTICE 2: Record that this event was successfully processed
      mark_as_processed!(event_id)
    end

    private

    def process_event(event_type, data)
      case event_type
      when "subscription_created"
        handle_subscription_created(data[:subscription])
      when "bill_paid"
        handle_bill_paid(data[:bill])
      else
        logger.info "Unhandled Vindi webhook event: #{event_type}"
      end
    end

    # BEST PRACTICE 3: Safe target state validations (e.g. ignore if already active/paid)
    def handle_subscription_created(subscription_data)
      return if subscription_data.nil?
      # e.g., Find local tenant/user using subscription_data[:customer][:code]
      # and activate their account.
    end

    def handle_bill_paid(bill_data)
      return if bill_data.nil?
      # e.g., Find local invoice by bill_data[:id]
      # and mark as paid. Check first if it isn't already paid.
    end

    def already_processed?(event_id)
      # e.g., VindiWebhookEvent.exists?(vindi_event_id: event_id)
      false
    end

    def mark_as_processed!(event_id)
      # e.g., VindiWebhookEvent.create!(vindi_event_id: event_id, processed_at: Time.current)
    end
  end
end
