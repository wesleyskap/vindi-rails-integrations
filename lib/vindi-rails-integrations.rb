# frozen_string_literal: true

require "vindi"
require_relative "vindi/integrations/version"
require_relative "vindi/integrations/railtie" if defined?(Rails)

module Vindi
  module Integrations
    class Error < StandardError; end
  end
end
