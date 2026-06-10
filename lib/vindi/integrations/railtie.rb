# frozen_string_literal: true

module Vindi
  module Integrations
    class Railtie < ::Rails::Railtie
      # Automatic loading of generators and integrations in Rails
      rake_tasks do
        load File.expand_path("../../../tasks/vindi/tasks.rake", __dir__)
      end
    end
  end
end
