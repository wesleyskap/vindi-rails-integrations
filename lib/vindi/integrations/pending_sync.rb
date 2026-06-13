# frozen_string_literal: true

module Vindi
  class PendingSync < ActiveRecord::Base
    self.table_name = "vindi_pending_syncs"

    if ActiveRecord.version >= Gem::Version.new("7.1.0")
      serialize :params, coder: JSON
    else
      serialize :params, JSON
    end

    validates :item_type, :item_id, :action, :status, presence: true
    validates :status, inclusion: { in: %w[pending processing processed failed] }

    scope :pending, -> { where(status: "pending") }
    scope :failed, -> { where(status: "failed") }
    scope :retryable, ->(max_attempts = 5) { where(status: %w[pending failed]).where("attempts < ?", max_attempts) }
  end
end
