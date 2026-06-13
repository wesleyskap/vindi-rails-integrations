# frozen_string_literal: true

module Vindi
  class ProcessPendingSyncsJob < ActiveJob::Base
    queue_as :default

    def perform(pending_sync_id = nil)
      if pending_sync_id
        pending_sync = Vindi::PendingSync.find_by(id: pending_sync_id)
        process_sync(pending_sync) if pending_sync
      else
        Vindi::PendingSync.retryable.find_each do |sync|
          process_sync(sync)
        end
      end
    end

    private

    def process_sync(pending_sync)
      return unless retryable?(pending_sync)

      pending_sync.update!(status: "processing")
      item = find_local_item(pending_sync)

      if item.nil?
        pending_sync.update!(status: "failed", last_error: "Record not found locally: #{pending_sync.item_type}##{pending_sync.item_id}")
        return
      end

      execute_api_call!(pending_sync, item)
      pending_sync.update!(status: "processed", last_error: nil)
    rescue StandardError => e
      handle_sync_failure(pending_sync, e)
    end

    def retryable?(pending_sync)
      %w[pending failed].include?(pending_sync.status)
    end

    def find_local_item(pending_sync)
      pending_sync.item_type.constantize.find_by(id: pending_sync.item_id)
    end

    def execute_api_call!(pending_sync, item)
      case pending_sync.action
      when "create", "update"
        sync_to_vindi(item.vindi_customer_id, pending_sync.params, item)
      else
        raise ArgumentError, "Unknown action #{pending_sync.action.inspect}. Expected 'create' or 'update'."
      end
    end

    def sync_to_vindi(customer_id, params, item)
      if customer_id.present?
        Vindi::Customer.update(customer_id, params)
      else
        customer = Vindi::Customer.create(params)
        item.update_columns(vindi_customer_id: customer.id.to_s)
      end
    end

    def handle_sync_failure(pending_sync, error)
      new_attempts = pending_sync.attempts + 1
      status = new_attempts >= 5 ? "failed" : "pending"
      pending_sync.update!(
        status: status,
        attempts: new_attempts,
        last_error: "#{error.class}: #{error.message}"
      )
    end
  end
end
