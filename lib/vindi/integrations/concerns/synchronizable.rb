# frozen_string_literal: true

module Vindi
  module Synchronizable
    extend ActiveSupport::Concern

    included do
      after_commit :create_vindi_customer, on: :create, unless: :vindi_customer_id?
      after_commit :update_vindi_customer, on: :update, if: :should_sync_vindi_update?
    end

    def sync_vindi_customer!
      return if vindi_customer_id?

      params = vindi_customer_attributes
      customer = Vindi::Customer.create(params)
      
      update_columns(vindi_customer_id: customer.id.to_s)
    rescue Vindi::Error => e
      Rails.logger.error("Failed to sync customer to Vindi: #{e.message}")
    end

    def update_vindi_customer!
      return unless vindi_customer_id?

      params = vindi_customer_attributes
      Vindi::Customer.update(vindi_customer_id, params)
    rescue Vindi::Error => e
      Rails.logger.error("Failed to update customer in Vindi: #{e.message}")
    end

    private

    def create_vindi_customer
      # Run in background or synchronously based on configuration
      sync_vindi_customer!
    end

    def update_vindi_customer
      update_vindi_customer!
    end

    def should_sync_vindi_update?
      vindi_customer_id? && (saved_change_to_name? || saved_change_to_email?)
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
