# frozen_string_literal: true

module Vindi
  module Synchronizable
    extend ActiveSupport::Concern

    included do
      after_create :record_vindi_create_pending_sync, if: :use_vindi_outbox?
      after_update :record_vindi_update_pending_sync, if: :should_record_vindi_update_sync?

      after_commit :create_vindi_customer, on: :create, if: :should_sync_vindi_create?
      after_commit :update_vindi_customer, on: :update, if: :should_sync_vindi_update?
    end

    def sync_vindi_customer!
      return unless synchronizable?
      return if vindi_customer_id?

      params = vindi_customer_attributes
      customer = Vindi::Customer.create(params)
      
      update_columns(vindi_customer_id: customer.id.to_s)
    rescue Vindi::Error => e
      Rails.logger.error("Failed to sync customer to Vindi: #{e.message}")
    end

    def update_vindi_customer!
      return unless synchronizable?
      return unless vindi_customer_id?

      params = vindi_customer_attributes
      Vindi::Customer.update(vindi_customer_id, params)
    rescue Vindi::Error => e
      Rails.logger.error("Failed to update customer in Vindi: #{e.message}")
    end

    def use_vindi_outbox?
      synchronizable? && Vindi.configuration.respond_to?(:use_outbox) && Vindi.configuration.use_outbox
    end

    def synchronizable?
      respond_to?(:vindi_customer_id) && self.class.name != "Vindi::PendingSync"
    end

    private

    def create_vindi_customer
      return unless synchronizable?
      if use_vindi_outbox?
        enqueue_vindi_outbox_processing
      else
        sync_vindi_customer!
      end
    end

    def update_vindi_customer
      return unless synchronizable?
      if use_vindi_outbox?
        enqueue_vindi_outbox_processing
      else
        update_vindi_customer!
      end
    end

    def should_sync_vindi_create?
      synchronizable? && !vindi_customer_id?
    end

    def should_sync_vindi_update?
      synchronizable? && vindi_customer_id? && (saved_change_to_name? || saved_change_to_email?)
    end

    def record_vindi_create_pending_sync
      return unless synchronizable?
      Vindi::PendingSync.create!(
        item_type: self.class.name,
        item_id: id,
        action: "create",
        params: vindi_customer_attributes,
        status: "pending"
      )
    end

    def record_vindi_update_pending_sync
      return unless synchronizable?
      Vindi::PendingSync.create!(
        item_type: self.class.name,
        item_id: id,
        action: "update",
        params: vindi_customer_attributes,
        status: "pending"
      )
    end

    def should_record_vindi_update_sync?
      use_vindi_outbox? && should_sync_vindi_update?
    end

    def enqueue_vindi_outbox_processing
      Vindi::ProcessPendingSyncsJob.perform_later
    end

    # Default attributes mapping. Override this in the ActiveRecord model
    # to customize parameters sent to Vindi (like registry_code, phone, etc.)
    def vindi_customer_attributes
      {
        name: try(:name),
        email: try(:email),
        code: id.to_s
      }
    end
  end
end
module Vindi
  module Integrations
    # Auto-load the concern when rails loads
    ActiveSupport.on_load(:active_record) do
      include Vindi::Synchronizable
    end
  end
end
