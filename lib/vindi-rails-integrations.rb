# frozen_string_literal: true

require "vindi"
require_relative "vindi/integrations/version"
require_relative "vindi/integrations/diagnostics"
require_relative "vindi/integrations/railtie" if defined?(Rails)
require_relative "vindi/integrations/concerns/synchronizable" if defined?(ActiveRecord)
require_relative "vindi/integrations/pending_sync" if defined?(ActiveRecord)
require_relative "vindi/jobs/process_pending_syncs_job" if defined?(ActiveJob)

module Vindi
  class Configuration
    attr_accessor :use_outbox
  end

  module Integrations
    class Error < StandardError; end
  end
end
